#!/usr/bin/python
import psycopg2

class Database:

    def __init__(self, config):
        self.conn = None
        self.params = config
        self.connect()

    def connect(self):
        """ Connect to the PostgreSQL database server """
        try:
            # connect to the PostgreSQL server
            print('[DEBUG] Connecting to the PostgreSQL database...')
            self.conn = psycopg2.connect(**self.params)

        except (Exception, psycopg2.DatabaseError) as error:
            print(error)

    def close(self):
        if self.conn is not None:
            self.conn.close()
            print('[DEBUG] Database connection closed.')
        
    def req(self, request):
        try:
            # create a cursor
            cur = self.conn.cursor()

            # execute a statement
            cur.execute(request)

            # display the PostgreSQL database server version
            # db_version = cur.fetchone()
            # print(db_version)

            self.conn.commit()

            # close the communication with the PostgreSQL
            cur.close()
        except (Exception, psycopg2.DatabaseError) as error:
            print("[ERROR]", error)

    def getVersion(self):
        # create a cursor
        cur = self.conn.cursor()
        
        # execute a statement
        print('PostgreSQL database version:')
        cur.execute('SELECT version()')
 
        # display the PostgreSQL database server version
        db_version = cur.fetchone()
        print(db_version)
       
        # close the communication with the PostgreSQL
        cur.close()



# if __name__ == '__main__':
#     database = Database()
#     database.getVersion()
#     database.close()
