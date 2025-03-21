import grpc
from concurrent import futures
import logging
import expense_pb2
import expense.expense_pb2_grpc as expense_pb2_grpc

class ExpenseService(expense_pb2_grpc.ExpenseServiceServicer):
    def GetExpense(self, request, context):
        """实现 GetExpense RPC 方法"""
        logging.info(f"收到来自用户 {request.user_id} 的请求")
        # 这里可以添加实际的业务逻辑，比如从数据库查询支出信息
        response = expense_pb2.ExpenseResponse()
        response.message = f"用户 {request.user_id} 的支出信息已获取"
        return response

def serve():
    """启动 gRPC 服务器"""
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    expense_pb2_grpc.add_ExpenseServiceServicer_to_server(
        ExpenseService(), server
    )
    server.add_insecure_port('[::]:50051')
    server.start()
    logging.info("gRPC 服务器在端口 50051 上运行")
    server.wait_for_termination()

if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    serve()