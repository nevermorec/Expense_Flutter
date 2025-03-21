import azure.functions as func
import logging
import json

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

# command_type is set to `Text`, since the constructor argument of the binding is a raw query.
@app.function_name(name="GetExpense")
@app.route(route="get_expense/{family}")
@app.sql_input(arg_name="expenses",
                        command_text="select * from expense_record where family = @Family",
                        command_type="Text",
                        parameters="@Family={family}",
                        connection_string_setting="SqlConnectionString")
def get_expense(req: func.HttpRequest, expenses: func.SqlRowList) -> func.HttpResponse:
    rows = list(map(lambda r: json.loads(r.to_json()), expenses))

    return func.HttpResponse(
        json.dumps(rows),
        status_code=200,
        mimetype="application/json"
    )

# curl -X GET http://localhost:7071/api/add_expense -d "{\"id\": \"1\", \"family\": \"test_family\"}"
@app.function_name(name="AddExpense")
@app.route(route="add_expense")
@app.sql_output(arg_name="expense",
                        command_text="[dbo].[expense_record]",
                        connection_string_setting="SqlConnectionString")
def add_expense(req: func.HttpRequest, expense: func.Out[func.SqlRow]) -> func.HttpResponse:
    body = json.loads(req.get_body())
    row = func.SqlRow.from_dict(body)
    expense.set(row)

    return func.HttpResponse(
        body=req.get_body(),
        status_code=201,
        mimetype="application/json"
    )

@app.function_name(name="AddExpense")
@app.route(route="add_expense")
@app.sql_output(arg_name="expense",
                        command_text="[dbo].[expense_record]",
                        connection_string_setting="SqlConnectionString")
def add_expense(req: func.HttpRequest, expense: func.Out[func.SqlRow]) -> func.HttpResponse:
    body = json.loads(req.get_body())
    row = func.SqlRow.from_dict(body)
    expense.set(row)

    return func.HttpResponse(
        body=req.get_body(),
        status_code=201,
        mimetype="application/json"
    )


@app.function_name(name="DeleteExpense")
@app.route(route="delete_expense")
@app.sql_input(arg_name="expense",
                        command_text="DeleteExpense",
                        command_type="StoredProcedure",
                        parameters="@Id={id}",
                        connection_string_setting="SqlConnectionString")
def delete_expense(req: func.HttpRequest, expense: func.SqlRowList) -> func.HttpResponse:
    rows = list(map(lambda r: json.loads(r.to_json()), expense))

    return func.HttpResponse(
        json.dumps(rows),
        status_code=200,
        mimetype="application/json"
    )


@app.route(route="expense")
def expense(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    if name:
        return func.HttpResponse(f"Hello, {name}. This HTTP triggered function executed successfully.")
    else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.",
             status_code=200
        )