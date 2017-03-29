#!/usr/bin/env python3

import os
import subprocess
import csv
import requests
import requests.exceptions
import sys
import time
import logging
import psycopg2
import json

# some setup
TOKEN_FILENAME = '/var/run/secrets/kubernetes.io/serviceaccount/token'
CA_CERT_FILENAME = '/var/run/secrets/kubernetes.io/serviceaccount/ca.crt'
API_URL = 'https://kubernetes.default.svc.cluster.local/api/v1/namespaces/{0}/pods/{1}'
NUM_ATTEMPTS = 10
LABEL = 'citus-role'
logger = logging.getLogger(__name__)

thisnode = os.environ["POD_NAME"]

# functions to handle kubernetes role changing
def change_host_role_label(new_role):
    try:
        with open(TOKEN_FILENAME, "r") as f:
            token = f.read()
    except IOError:
        sys.exit("Unable to read K8S authorization token")

    headers = {'Authorization': 'Bearer {0}'.format(token)}
    headers['Content-Type'] = 'application/json-patch+json'
    url = API_URL.format(os.environ.get('POD_NAMESPACE', 'default'),
                         os.environ['HOSTNAME'])
    data = [{'op': 'add', 'path': '/metadata/labels/{0}'.format(LABEL), 'value': new_role}]
    for i in range(NUM_ATTEMPTS):
        try:
            r = requests.patch(url, headers=headers, data=json.dumps(data), verify=CA_CERT_FILENAME)
            if r.status_code >= 300:
                logger.warning("Unable to change the role label to {0}: {1}".format(new_role, r.text))
            else:
                break
        except requests.exceptions.RequestException as e:
            logger.warning("Exception when executing POST on {0}: {1}".format(url, e))
        time.sleep(1)
    else:
        logger.warning("Unable to set the label after {0} attempts".format(NUM_ATTEMPTS))


def record_role_change(new_role):
    # on stop always sets the label to the replica, the load balancer
    # should not direct connections to the hosts with the stopped DB.
    change_host_role_label(new_role)
    logger.debug("Changing the host's role to {0}".format(new_role))


def exec_check(cmd):
    try:
        subprocess.run(cmd, stderr=subprocess.PIPE, check=True)
    except subprocess.CalledProcessError as e:
        print(e.cmd, " errored:")
        print(e.stderr)
        sys.exit(1)

    logger.debug("executed command {0}".format(cmd))

def connect_db(dbhost,dbname="template1"):
    if dbhost == "localhost":
        conn = psycopg2.connect("dbname={0}".format(dname))
    else:
        # poll connections in case the query node isn't up yet
        conn = None
        for poll in range(1,10):
            try:
                conn = psycopg2.connect("dbname={0} host={1} user=postgres".format(dbname, dbhost))
                break
            except:
                sleep(5 * poll)
    if conn is None:
        raise Exception('Unable to reach the query node, failing startup')
    conn.autocommit = True
    return conn

# function to get register node in all active databases
def register_in_all_db(queryhost,shardname):
    conn=connect_db(queryhost)
    cur=conn.cursor()
    # add/remove from template1
    cur.execute("SELECT master_add_node(%s,5432)",(shardname,remove,))
    # get list of databases
    cur.execute("SELECT string_to_array(datname::TEXT) FROM pg_database WHERE datname NOT IN ('template1','template0')")
    rows = cur.fetchall()
    dblist = rows[0]
    conn.close()
    # loop over databases, registering in each
    for dbname in dblist:
        conn=connect_db(queryhost,dbname)
        cur=conn.cursor()
        cur.execute("SELECT citus_register_node(%s,5432)",(shardname))
        conn.close()

    return True

# start postgresql
exec_check(["/usr/bin/pg_ctl","-D","/pgdata/data","-w","start"])

# check if weve set permissions etc.:
if not os.path.exists('/pgdata/data/initialized'):
  # create dictionary from env secrets
  pwds = { "postgres": os.getenv("SUPERPASS", "citus"),
            "admin" : os.getenv("ADMINPASS", "citus"),
            "replicator": os.getenv("REPPASS", "citus") }
  # create .pgpass file
  with open("/var/lib/pgsql/.pgpass", "w") as passfile:
      passwriter = csv.writer(passfile, delimiter=":", lineterminator="\n", quoting=csv.QUOTE_MINIMAL)
      for usr, pwd in pwds.items():
          passwriter.writerow(["*","*","*",usr,pwd])

  os.chmod("/var/lib/pgsql/.pgpass",0o700)

  # create users and set passwords
  conn = psycopg2.connect("dbname=template1")
  conn.autocommit = True
  cur = conn.cursor()
  cur.execute("ALTER ROLE postgres PASSWORD '{0}'".format(pwds["postgres"]))
  cur.execute("CREATE ROLE admin PASSWORD '{0}' LOGIN CREATEDB".format(pwds["admin"]))
  cur.execute("CREATE ROLE replicator PASSWORD '{0}' LOGIN REPLICATION".format(pwds["replicator"]))
  # update template1 with citus extension and register function
  cur.execute("CREATE EXTENSION citus")
  exec_check(["/usr/bin/psql","-f","/scripts/register_nodes.sql", "template1"])

  # are we the query node?  if so, set nodes in template1
  # since we might be launching as a replacement
  if thisnode.endswith("-0"):
      pod_domain = "{0}.svc.cluster.local".format(os.getenv("POD_NAMESPACE", "default"))
      cur.execute("SELECT register_nodes(%s, %s, %s)",
        (os.getenv("SET_SIZE"),os.getenv("POD_GROUP"),pod_domain))

  # recreate postgres database so that it gets that stuff
  cur.execute("DROP DATABASE postgres")
  cur.execute("CREATE DATABASE postgres")
  # create a "citusdb" database:
  cur.execute("CREATE DATABASE citusdb OWNER admin")
  conn.close()

  # are we a shard?  if so, poll the master for the list of databases
  # and register this node in each one
  if not thisnode.endswith("-0"):
      pod_domain = "{0}.svc.cluster.local".format(os.getenv("POD_NAMESPACE", "default"))
      master_uri = "{0}-0.{0}.{1}".format(os.genenv("POD_GROUP"),pod_domain)
      thisnode_uri = "{0}.{1}.{2}".format(thisnode,os.getenv("POD_GROUP"),pod_domain)
      register_in_all_db(master_uri,thisnode_uri)

  # set initialized key
  open("/pgdata/data/initialized", 'a').close()

# update status in kubernetes
if thisnode.endswith("-0"):
    record_role_change("query")
else:
    record_role_change("shard")

# restart postgres to attach to terminal
exec_check(["/usr/bin/pg_ctl","-D","/pgdata/data","-w","stop"])
os.execv("/usr/bin/postgres",["/usr/bin/postgres","-D","/pgdata/data"])

# ready message
print("Node {0} running and ready to accept queries.".format())
