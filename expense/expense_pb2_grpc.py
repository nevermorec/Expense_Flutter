# Generated by the gRPC Python protocol compiler plugin. DO NOT EDIT!
"""Client and server classes corresponding to protobuf-defined services."""
import grpc

import expense_pb2 as expense__pb2


class ExpenseServiceStub(object):
    """Define the service
    """

    def __init__(self, channel):
        """Constructor.

        Args:
            channel: A grpc.Channel.
        """
        self.GetExpense = channel.unary_unary(
                '/expense.ExpenseService/GetExpense',
                request_serializer=expense__pb2.ExpenseRequest.SerializeToString,
                response_deserializer=expense__pb2.ExpenseResponse.FromString,
                )


class ExpenseServiceServicer(object):
    """Define the service
    """

    def GetExpense(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')


def add_ExpenseServiceServicer_to_server(servicer, server):
    rpc_method_handlers = {
            'GetExpense': grpc.unary_unary_rpc_method_handler(
                    servicer.GetExpense,
                    request_deserializer=expense__pb2.ExpenseRequest.FromString,
                    response_serializer=expense__pb2.ExpenseResponse.SerializeToString,
            ),
    }
    generic_handler = grpc.method_handlers_generic_handler(
            'expense.ExpenseService', rpc_method_handlers)
    server.add_generic_rpc_handlers((generic_handler,))


 # This class is part of an EXPERIMENTAL API.
class ExpenseService(object):
    """Define the service
    """

    @staticmethod
    def GetExpense(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/expense.ExpenseService/GetExpense',
            expense__pb2.ExpenseRequest.SerializeToString,
            expense__pb2.ExpenseResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)
