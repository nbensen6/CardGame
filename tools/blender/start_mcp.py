## Opens Blender with the MCP socket already listening.
##
## The addon normally wants you to press N, find the BlenderMCP tab and click
## Start MCP Server. This does that for you, one frame after the window exists.
import bpy

def _go():
    try:
        bpy.ops.blendermcp.start_server()
        print("BLENDERMCP listening on port", bpy.context.scene.blendermcp_port)
    except Exception as e:
        print("BLENDERMCP failed to start:", type(e).__name__, e)
    return None   # never run again

bpy.app.timers.register(_go, first_interval=1.0)
