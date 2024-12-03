#pip install hdbcli

from hdbcli import dbapi

conn = dbapi.connect(
    address="10.0.4.4",       # The hostname or IP address of the SAP HANA server
    port=30113,         # The port number (e.g., 30015 for single-tenant databases)
    user="SYSTEM",          # The username for authentication
    password="Saphana-vm-02-suse",      #alse if using a self-signed certificate
    databaseName="A01",   # The name of the database (optional)
)

# Query data from a sample table
cursor = conn.cursor()
cursor.execute('SELECT TOP 1000 * FROM "AZURE_VM_RS"."CONTACTS"')
data = cursor.fetchall()

# Process the data (example: print the data)
for row in data:
    print(row)

# Close the connection
conn.close()
