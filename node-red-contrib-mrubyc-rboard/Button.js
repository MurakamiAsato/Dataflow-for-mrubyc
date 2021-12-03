module.exports = function(RED) {
	var node;
	function ButtonNode(config) {
		RED.nodes.createNode(this,config);
		node = this;

	}
	RED.nodes.registerType("Button",ButtonNode);

	RED.httpAdmin.post("/Button/:id", RED.auth.needsPermission("Button.write"), function(req,res) {
		var addminNode = RED.nodes.getNode(req.params.id);
		if (addminNode != null) {
			try {
				addminNode.receive();
				node.send({payload:1});
				res.sendStatus(200);
			} catch(err) {
				res.sendStatus(500);
				addminNode.error(RED._("Button.failed",{error:err.toString()}));
			}
		} else {
			res.sendStatus(404);
		}
	});
}
