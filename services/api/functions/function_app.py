import azure.functions as func
import azure.durable_functions as df
import json
import logging
from azure.durable_functions import DurableOrchestrationContext

# app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)
app = df.DFApp(http_auth_level=func.AuthLevel.FUNCTION)


@app.route(route="myfunction1")
async def myfunction1(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Python HTTP trigger function processed a request.")

    name = req.params.get("name")
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get("name")

    if name:
        response = {
            "message": f"Hello, {name}. This HTTP triggered function executed successfully."
        }
    else:
        response = {
            "message": "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."
        }

    # Return the JSON response
    return func.HttpResponse(
        json.dumps(response), mimetype="application/json", status_code=200
    )


# An HTTP-triggered function with a Durable Functions client binding
@app.route(route="orchestrators/{functionName}")
@app.durable_client_input(client_name="client")
async def http_start(req: func.HttpRequest, client):
    function_name = req.route_params.get("functionName")
    instance_id = await client.start_new(function_name)
    response = client.create_check_status_response(req, instance_id)
    return response


# Orchestrator
@app.orchestration_trigger(context_name="context")
def hello_orchestrator(context: DurableOrchestrationContext):
    tasks = []
    tasks.append(context.call_activity("hello", "Seattle"))
    tasks.append(context.call_activity("hello", "Tokyo"))
    tasks.append(context.call_activity("hello", "London"))

    results = yield context.task_all(tasks)
    return results


# Activity
@app.activity_trigger(input_name="city")
def hello(city: str):
    return f"Hello {city}"
