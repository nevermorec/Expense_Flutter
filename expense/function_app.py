import azure.functions as func
import logging
import json
import pyodbc
import os

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

# create table expense_record
# (
#     id       int      not null
#         primary key,
#     family   char(30) not null,
#     category int,
#     number   float,
#     remark   text
# )



def get_sql_conn():
    conn_str = "Driver={ODBC Driver 18 for SQL Server};Server=tcp:expense-karlos.database.windows.net,1433;Database=Expense;Uid=karlos;Pwd=123123125Ab;Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
    if not conn_str:
        return func.HttpResponse(
            "Database connection string not configured",
            status_code=500
        )
        
    # 连接数据库
    conn = pyodbc.connect(conn_str)
    return conn

@app.route(route="get_expense")
def get_expense(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    
    try:
        conn = get_sql_conn()
        cursor = conn.cursor()
        
        # 执行查询
        cursor.execute("SELECT * FROM expense_record")
        
        # 获取列名
        columns = [column[0] for column in cursor.description]
        
        # 获取所有记录
        records = []
        for row in cursor.fetchall():
            record = dict(zip(columns, row))
            records.append(record)
            
        # 关闭数据库连接
        cursor.close()
        conn.close()
        
        # 返回JSON格式的结果
        return func.HttpResponse(
            json.dumps({"expenses": records}, default=str),
            mimetype="application/json",
            status_code=200
        )
        
    except Exception as e:
        logging.error(f"Error querying expenses: {str(e)}")
        return func.HttpResponse(
            f"Error occurred while retrieving expenses: {str(e)}",
            status_code=500
        )
    
curl -X POST "https://741096681b.azurewebsites.net/api/delete_expense?code=0PYf2UXZN0WlbtGZzUBzRZkRq386gPamAE8DZWmyvzKlAzFuJIDn0A%3D%3D" \
-H "Content-Type: application/json" \
-d '{
    "id": 1,
    "family": "f_123"
}'
@app.route(route="insert_expense")
def insert_expense(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request for inserting an expense.')

    try:
        # 获取请求体中的数据
        req_body = req.get_json()
        id = req_body.get('id')
        family = req_body.get('family')
        category = req_body.get('category')
        number = req_body.get('number')
        remark = req_body.get('remark')
        date_time = req_body.get('date_time')

        # 检查必要字段是否存在
        if not all([id, family, number, category, date_time]):
            return func.HttpResponse(
                "Missing required fields: id, family, number",
                status_code=400
            )

        # 连接数据库
        conn = get_sql_conn()
        cursor = conn.cursor()

        # 插入数据
        cursor.execute(
            "INSERT INTO expense_record (id, family, category, number, remark, date_time) VALUES (?, ?, ?, ?, ?, ?)",
            (id, family, category, number, remark, date_time)
        )

        # 提交事务
        conn.commit()

        # 关闭数据库连接
        cursor.close()
        conn.close()

        return func.HttpResponse(
            "Expense record inserted successfully.",
            status_code=201
        )

    except Exception as e:
        logging.error(f"Error inserting expense: {str(e)}")
        return func.HttpResponse(
            f"Error occurred while inserting expense: {str(e)}",
            status_code=500
        )

@app.route(route="delete_expense")
def delete_expense(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request for deleting an expense.')

    try:
        # 获取请求体中的数据
        req_body = req.get_json()
        id = req_body.get('id')
        family = req_body.get('family')

        # 检查必要字段是否存在
        if not all([id, family]):
            return func.HttpResponse(
                "Missing required fields: id, family",
                status_code=400
            )

        # 连接数据库
        conn = get_sql_conn()
        cursor = conn.cursor()

        # 删除数据
        cursor.execute(
            "DELETE FROM expense_record WHERE id = ? AND family = ?",
            (id, family)
        )

        # 检查是否删除了记录
        if cursor.rowcount == 0:
            return func.HttpResponse(
                "No record found with the provided id and family.",
                status_code=404
            )

        # 提交事务
        conn.commit()

        # 关闭数据库连接
        cursor.close()
        conn.close()

        return func.HttpResponse(
            "Expense record deleted successfully.",
            status_code=200
        )

    except Exception as e:
        logging.error(f"Error deleting expense: {str(e)}")
        return func.HttpResponse(
            f"Error occurred while deleting expense: {str(e)}",
            status_code=500
        )