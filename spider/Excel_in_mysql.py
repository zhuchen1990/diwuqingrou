from openpyxl import load_workbook
import pymysql

config = {
    'host': '193.112.69.164',
    'port': 3306,
    'user': 'root',
    'password': 'qq291394199',
    'charset': 'utf8mb4',
    # 'cursorclass': pymysql.cursors.DictCursor

}
conn = pymysql.connect(**config)
conn.autocommit(1)
cursor = conn.cursor()
name = 'yhexcel'
cursor.execute('create database if not exists %s' % name)
conn.select_db(name)
table_name = 'info'
cursor.execute(
    'create table if not exists %s(name varchar(30),star_con varchar(30),score varchar(30),info_list varchar(30))' % table_name)

wb2 = load_workbook('mv.xlsx')
ws = wb2.get_sheet_names()
for row in wb2:
    print("1")
    for cell in row:
        # BUG
        value1 = (cell[0].value, cell[4].value)
        value2 = (cell[0].value, cell[3].value)
        value3 = (cell[0].value, cell[3].value)
        value4 = (cell[0].value, cell[3].value)
        cursor.execute('insert into info (name,star_con,score,info_lis) values(%s,%s,%s,%s)', value1, value2, value3,
                       value4)

print("overing...")
# for row in A:
# 	print(row)
# print (wb2.get_sheet_names())
