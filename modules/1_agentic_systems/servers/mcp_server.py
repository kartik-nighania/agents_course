from mcp.server.fastmcp import FastMCP
import os
import json

mcp = FastMCP("user_info", port=os.environ['PORT'])

@mcp.tool()
async def get_user_details(user_id: str) -> str:
    """Given a user id. This tool can get the user details"""
    user_data = {"user_id": user_id, "name": "John", "location": "Bangalore"}
    return json.dumps(user_data)

if __name__ == "__main__":
    mcp.run(transport="sse")