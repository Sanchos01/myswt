web_interface = angular.module "web_interface", ["ngTable", "ngCookies"] 
controllers = {}
controllers.my_controller = ($scope, $http, $interval, $cookieStore) ->
	$scope.init_const_and_vars = () ->
		term = {on: [], off: []}
		$scope.search = {}
		$scope.search.terminals = {}
		$scope.search.filters = {}
		$scope.search.stat = {}
		if $cookieStore.get("opts") == undefined
			$scope.opts = {}
			$scope.opts.current_showing_type = "auth"
			$scope.opts.task_cols = [
						{ field: 'uuid', visible: true },
						{ field: 'comment', visible: true },
						{ field: 'ids', visible: true },
						{ field: 'type', visible: true },
						{ field: 'override', visible: true }
						{ field: 'status', visible: true }
					]
			$scope.opts.access_token = ""
			$scope.opts.proxy = ""
			$scope.opts.my_uid = 0
		else
			$scope.opts = $cookieStore.get("opts")
		$scope.cached = {}
		$scope.cached.task_new = {comment: "", ids: "", type: "group", override: false}
	$scope.send_message = (mess) ->
		$scope.bullet.send(JSON.stringify(mess))
	$scope.auth = (token, my_uid, proxy) ->
		$cookieStore.put("opts", $scope.opts)
		$scope.send_message {"subject": "auth", "content": {"token": token, "uid": my_uid, "proxy": proxy}}
	$scope.init = () ->
		$scope.init_const_and_vars()
		$scope.bullet = $.bullet("ws://" + location.host + "/bullet")
		$scope.bullet.onopen = () ->
			console.log("bullet: connected")
		$scope.bullet.ondisconnect = () ->
			console.log("bullet: disconnected")
		$scope.bullet.onclose = () ->
			console.log("bullet: closed")
		$scope.bullet.onmessage = (e) ->
			mess = $.parseJSON(e.data)
			if mess.subject == "error" 
				$.growl.error({ message: mess.content , duration: 20000})
			else if mess.subject == "warn"
				$.growl.warning({ message: mess.content , duration: 20000})
			else if mess.subject == "notice"
				$.growl.notice({ message: mess.content , duration: 20000})
			else if mess.subject == "auth"
				$scope.opts.current_showing_type = "vk_db"
				$.growl.notice({ message: mess.content , duration: 20000})
			else if mess.subject == "pong"
				"ok"
			else
				alert "Unexpected message = "+e.data
		$scope.bullet.onheartbeat = () ->
			$scope.send_message {"subject": "ping","content": "nil"}
		$interval( $scope.bullet.onheartbeat , 1000, [], [])
web_interface.controller(controllers)