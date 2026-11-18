###################
# HAPPYBASE SETUP #
###################

import happybase

# Un ThriftServer tourne sur chaque slave Yarn (voir start-thrift.sh) :
# localhost:9090 est donc la passerelle HBase locale du container.
connection = happybase.Connection(host='localhost', port=9090)
TABLE_NAME = b'streams'

if TABLE_NAME not in connection.tables():
    connection.create_table(TABLE_NAME, {
        "year": dict(),
        "streams": dict()
    })

table = connection.table(TABLE_NAME)

###########
# REDUCER #
###########

import sys
reader = sys.stdin

current_year = None
total_streams = 0

for line in reader:
    year, streams = line.strip().split("\t")

    try:
        streams = int(streams)
    except ValueError:
        continue

    if year == current_year:
        total_streams += streams
    else:
        if current_year is not None: # 1ere ligne
            table.put(current_year.encode(), {b"streams:total": str(total_streams).encode()})
        current_year = year
        total_streams = streams

if current_year is not None: # derniere ligne
    table.put(current_year.encode(), {b"streams:total": str(total_streams).encode()})

##############################
# CLOSE HAPPYBASE CONNECTION #
##############################

connection.close()
