
import csv
import psycopg2

# Connect to an existing database
conn = psycopg2.connect("dbname='postgres' user='ricedb' host='localhost' password='qwe123'")

# Open a cursor to perform database operations
# Read data from a user-provided filename in the client’s file system, and add the data intothedatabase;
sFilename = '533.csv'
eFile = open(sFilename)  
  
eReader=csv.reader(eFile)
temp_2=0;

cur = conn.cursor()

cur.callproc('CreateOrg',[])
cur.callproc('CreateDistance',[])
cur.callproc('CreateLeg',[])
cur.callproc('CreateStroke',[])
cur.callproc('CreateMeet',[])
cur.callproc('CreateParticipant',[])
cur.callproc('CreateEvent',[])
cur.callproc('CreateStrokeOf',[])
cur.callproc('CreateHeat',[])
cur.callproc('CreateSwim',[])

for row in eReader:  
    if '*' in str(row):
        temp_2=temp_2+1
    else:
        if temp_2==1:
            cur.callproc('InsertOrg', [row[0],row[1],row[2],])
        elif temp_2 == 2:
            cur.callproc('InsertMeet', [row[0], row[1], row[2], row[3],])
        elif temp_2 == 3:
            cur.callproc('InsertParticip', [row[0],row[1],row[2],row[3],])
        elif temp_2 == 4:
            cur.callproc('Insert_Leg', [row[0], ])
        elif temp_2 == 5:
            cur.callproc('InsertStroke', [row[0],])
        elif temp_2 == 6:
            cur.callproc('InsertDistance', [row[0],])
        elif temp_2 == 7:
            cur.callproc('InsertEvent', [row[0],row[1],row[2],])
        elif temp_2 == 8:
            cur.callproc('Insert_StrokeOf', [row[0],row[1],row[2],])
        elif temp_2 == 9:
            cur.callproc('InsertHeat', [row[0],row[1],row[2],])
        else:
            cur.callproc('Insert_Swim', [row[0],row[1],row[2],row[3],row[4],row[5],])

        conn.commit()

cur.callproc('CreateView', [])
conn.commit()
            # Close communication with the database
cur.close()
conn.close()

###### output data, save all data to a user-provided filename. Use the same file format as for reading;
def savecsv():
    conn = psycopg2.connect("dbname='postgres' user='ricedb' host='localhost' password='qwe123'")
    cur = conn.cursor()
    names = ["Org" ,"Meet", "Participant", "Leg", "Stroke", "Distance", "Event", "StrokeOf", "Heat", "Swim"]
    file_name = input("*************\nSave data, Please input your file name (Do not input the same name with the read file and ADD the .csv)\n: ")
    csvfile = open(file_name, 'w')
    writer = csv.writer(csvfile)
    
    for name in names:
        writer.writerow(('*' + name,))
        qry = "select * from "
        qry = qry + name
        cur.execute(qry)
        rows = cur.fetchall()
        for row in rows:
            writer.writerow(row)
    csvfile.close()
    cur.close()
    conn.close()


###### For each table, enter a row of data. The user should be reminded or prompted as to what data is expected in what order;
######If you enter a row of data which conflicts with other rows in primary key, then the record is updated.
def enterrow():
    conn = psycopg2.connect("dbname='postgres' user='ricedb' host='localhost' password='qwe123'")
    cur = conn.cursor()
    table_name = input("*********\nPlease input the table name that you want to insert\n['Org' ,'Meet', 'Participant', 'Leg', 'Stroke', 'Distance', 'Event', 'StrokeOf', 'Heat', 'Swim']\n: ")
    if table_name == 'Org' or table_name == 'org':
        print("Attributes: id CHAR(4), name VARCHAR(20), is_univ BOOLEAN.")
        lines = input("Enter values: ")
        line = lines.split()
        try:
            cur.callproc('InsertOrg', (str(line[0]), str(line[1]), line[2],))
            conn.commit()
        except ProgrammingError:
            conn.rollback()
    elif table_name == 'Meet' or table_name == 'meet':
        print("Attributes: name VARCHAR(20), start_date DATE, num_days INT, org_id CHAR(4).")
        lines = input("Enter values: ")
        line = lines.split()
        try:
            cur.callproc('InsertMeet', (str(line[0]), line[1], int(line[2]), str(line[3]),))
            conn.commit()
        except ProgrammingError:
            conn.rollback()
    elif table_name == 'Participant' or table_name == 'participant':
        print("Attributes: id CHAR(7), gender CHAR (1), org_id CHAR(4), name VARCHAR(20).")
        lines = input("Enter values: ")
        line = lines.split()
        try:
            cur.callproc('InsertParticip', (str(line[0]), str(line[1]), str(line[2]), str(line[3]),))
            conn.commit()
        except ProgrammingError:
            conn.rollback()
    elif table_name == 'Distance' or table_name == 'distance':
        print("Attributes: distance integer.")
        lines = input("Enter values: ")
        line = lines.split()
        try:
            cur.callproc('InsertDistance', (int(line[0]),))
            conn.commit()
        except ProgrammingError:
            conn.rollback()
    elif table_name == 'Stroke' or table_name == 'stroke':
        print("Attributes: stroke VARCHAR(20).")
        lines = input("Enter values: ")
        line = lines.split()
        try:
            cur.callproc('InsertStroke', (str(line[0]),))
            conn.commit()
        except ProgrammingError:
            conn.rollback()
    elif table_name == 'Leg' or table_name == 'leg':
        print("Attributes: leg INT.")
        lines = input("Enter values: ")
        line = lines.split()
        try:
            cur.callproc('Insert_Leg', (int(line[0]),))
            conn.commit()
        except ProgrammingError:
            conn.rollback()
    elif table_name == 'Event' or table_name == 'event':
        print("Attributes: id CHAR(5), gender CHAR(1), distance integer.")
        lines = input("Enter values: ")
        line = lines.split()
        try:
            cur.callproc('InsertEvent', (str(line[0]), str(line[1]), int(line[2]),))
            conn.commit()
        except ProgrammingError:
            conn.rollback()
    elif table_name == 'StrokeOf' or table_name == 'strokeof':
        print("Attributes: event_id CHAR(5), leg INT, stroke VARCHAR(20).")
        lines = input("Enter values: ")
        line = lines.split()
        try:
            cur.callproc('Insert_StrokeOf', (str(line[0]), int(line[1]), str(line[2]),))
            conn.commit()
        except ProgrammingError:
            conn.rollback()
    elif table_name == 'Heat' or table_name == 'heat':
        print("Attributes: id INT, event_id CHAR(5), meet_name VARCHAR(20).")
        lines = input("Enter values: ")
        line = lines.split()
        try:
            cur.callproc('InsertHeat', (int(line[0]), str(line[1]), str(line[2]),))
            conn.commit()
        except ProgrammingError:
            conn.rollback()
    elif table_name == 'Swim' or table_name == 'swim':
        print("Attributes: heat_id INT, event_id CHAR(5), meet_name VARCHAR(20), participant_id CHAR(7), leg INT, time decimal.")
        lines = input("Enter values: ")
        line = lines.split()
        try:
            cur.callproc('Insert_Swim', (int(line[0]), str(line[1]), str(line[2]), str(line[3]), int(line[4]), float(line[5]),))
            conn.commit()
        except ProgrammingError:
            conn.rollback()
    cur.close()
    conn.close()

    ######### For the Participant, Event, and Org tables, update a row of data, given the primary key(we .



    ######### We will only consider per-Event ranks. Their fastest time in the event is ranked, and their slower times are ignored for the ranking;
    ######### for a meet, display a heat sheet;
def meettoheat():
    conn = psycopg2.connect("dbname='postgres' user='ricedb' host='localhost' password='qwe123'")
    cur = conn.cursor()
    meet = input("*********\nPlease input the meet that you want to display the heat.\n(ex: 'NCAA_Summer', 'Rice Invitational','SouthConfed')\n: ")
    try:
        cur.callproc('MeetToHeat', (meet,))
        conn.commit()
        print('individual_rank: ')
        print('| event_id | heat_id | participant_id | swimmer_name | school | time | rank |')
        qry = "select * from heat_result1"
        cur.execute(qry)
        rows = cur.fetchall()
        for row in rows:
            print(row)

        print('relay_rank: ')
        print('| event_id | heat_id | participant_id | swimmer_name | school | time | team_time | rank |')
        qry = "select * from heat_result2"
        cur.execute(qry)
        rows = cur.fetchall()
        for row in rows:
            print(row)
    except ProgrammingError:
        conn.rollback()
    cur.close()
    conn.close()

########## For a Participant and Meet, display a Heat Sheet limited to just that swimmer,including any relays they are in;
def mptoheat():
    conn = psycopg2.connect("dbname='postgres' user='ricedb' host='localhost' password='qwe123'")
    cur = conn.cursor()
    meet = input("*********\nPlease input the  participant name and meet that you want to display the heat.\n(ex: 'Mohammad NCAA_Summer', 'Stephanie Rice Invitational','Lisa SouthConfed')\n: ")
    try:
        line = meet.split()
        if len(line) == 3:
            line[1] = line[1] + ' ' + line[2]
        cur.callproc('PMToHeat', (line[0], line[1],))
        conn.commit()
        print('Individual_event: ')
        print('| event_id | heat_id | school | time | rank |')
        qry = "select * from pm_result"
        cur.execute(qry)
        rows = cur.fetchall()
        for row in rows:
            print(row)
        print('Relay_event: ')
        qry = "select * from pm_result1"
        cur.execute(qry)
        rows = cur.fetchall()
        for row in rows:
            print(row)
    except ProgrammingError:
        conn.rollback()
    cur.close()
    conn.close()

########## For a School and Meet, display a Heat Sheet limited to just that School’s swimmers;
def mstoheat():
    conn = psycopg2.connect("dbname='postgres' user='ricedb' host='localhost' password='qwe123'")
    cur = conn.cursor()
    meet = input("*********\nPlease input the  school name and meet that you want to display the heat.\n(ex: 'RICE SouthConfed', 'Baylor NCAA_Summer','RICE Rice Invitational')\n: ")
    try:
        line = meet.split()
        if len(line) == 3:
            line[1] = line[1] + ' ' + line[2]
        cur.callproc('SMToHeat', (line[0], line[1],))
        conn.commit()
        print('Individual_event: ')
        print('| event_id | heat_id | participant_id | swimmer_name | time | rank |')
        qry = "select * from sm_result"
        cur.execute(qry)
        rows = cur.fetchall()
        for row in rows:
            print(row)
        print('realy_event: ')
        print('| event_id | heat_id | participant_id | swimmer_name | time | team_time | rank |')
        qry = "select * from sm_result1"
        cur.execute(qry)
        rows = cur.fetchall()
        for row in rows:
            print(row)
    except ProgrammingError:
        conn.rollback()
    cur.close()
    conn.close()

########## For a School and Meet, display just the names of the competing swimmers;
def mstoswimmer():
    conn = psycopg2.connect("dbname='postgres' user='ricedb' host='localhost' password='qwe123'")
    cur = conn.cursor()
    meet = input("*********\nPlease input the  school name and meet that you want to display the swimmer.\n(ex: 'RICE SouthConfed', 'Baylor NCAA_Summer','RICE Rice Invitational')\n: ")
    try:
        line = meet.split()
        if len(line) == 3:
            line[1] = line[1] + ' ' + line[2]
        cur.callproc('SMToSwimmer', (line[0], line[1],))
        conn.commit()
        qry = "select * from sm_swim_result"
        print('| swimmer_name |')
        cur.execute(qry)
        rows = cur.fetchall()
        for row in rows:
            print(row)
    except ProgrammingError:
        conn.rollback()
    cur.close()
    conn.close()

########## For an Event and Meet, display all results sorted by time. Include the heat,swimmer(s) name(s), and rank;
def emtoheat():
    conn = psycopg2.connect("dbname='postgres' user='ricedb' host='localhost' password='qwe123'")
    cur = conn.cursor()
    meet = input("*********\nPlease input the  event_id and meet that you want to display the swimmer.\n(ex: 'E1107 SouthConfed', 'E0107 NCAA_Summer','E0407 Rice Invitational')\n: ")
    try:
        line = meet.split()
        if len(line) == 3:
            line[1] = line[1] + ' ' + line[2]
        cur.callproc('EMToHeat', (line[0], line[1],))
        conn.commit()
        print('Individual_event: ')
        print('| heat_id | swimmer_name | participant_id ｜ school | time | rank |')
        qry = "select * from em_result"
        cur.execute(qry)
        rows = cur.fetchall()
        for row in rows:
            print(row)
        print('realy_event: ')
        print('| heat_id | swimmer_name | participant_id ｜ school | time | team_time | rank |')
        qry = "select * from em_result1"
        cur.execute(qry)
        rows = cur.fetchall()
        for row in rows:
            print(row)

    except ProgrammingError:
        conn.rollback()
    cur.close()
    conn.close()


######### For a Meet, display the scores of each school, sorted by scores, and calculated the score;
def calscore():
    conn = psycopg2.connect("dbname='postgres' user='ricedb' host='localhost' password='qwe123'")
    cur = conn.cursor()
    meet = input("*********\nPlease input the  meet name.\n(ex: 'SouthConfed', 'NCAA_Summer','Rice Invitational')\n: ")

    try:
        cur.callproc('CalScore', (meet,))
        conn.commit()
        print('| school | grade |')
        qry = "select school,grade::int from sco_result"
        cur.execute(qry)
        rows = list(cur)
        for row in rows:
            print(row)
    except ProgrammingError:
        conn.rollback()
    cur.close()
    conn.close()

######### the body of application

if __name__ == '__main__':

    while(True):
        res = input("*********\nPlease choose the number of actions:\n1.save file.\n2. insert(update) the row.\n3.For a Meet, display a Heat Sheet.\n4. For a Participant and Meet, display a Heat Sheet.\n5. For a School and Meet, display a Heat Sheet.\n6. For a School and Meet, display just the names of the competing swimmers.\n7. For an Event and Meet, display all results sorted by time.\n8. For a Meet, display the scores. \n9. exit.\n:")
        if res == '1':
            savecsv()
            print ("save successfully!")
        elif res == '2':
            enterrow()
            print ("insert successfully!")
        elif res == '3':
            meettoheat()
            print ("work successfully!")
        elif res == '4':
            mptoheat()
            print ("work successfully!")
        elif res == '5':
            mstoheat()
            print ("work successfully!")
        elif res == '6':
            mstoswimmer()
            print ("work successfully!")
        elif res == '7':
            emtoheat()
            print ("work successfully!")
        elif res == '8':
            calscore()
            print ("work successfully!")
        elif res == '9':
            print ("finished!")
            break
