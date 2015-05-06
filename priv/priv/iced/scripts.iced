web_interface = angular.module "web_interface", ["ngTable", "ngCookies"] 
controllers = {}
controllers.my_controller = ($scope, $http, $interval, $cookieStore) ->
	#
	#	interface handlers
	#
	$scope.foo = (foo) ->
		$scope.send_message("foo", foo)
	$scope.bar = (bar) ->
		$scope.send_message("bar", bar)
	#
	#	proto callbacks
	#
	$scope.init_const_and_vars = () ->
		$scope.search = {}
		if $cookieStore.get("opts") == undefined
			$scope.opts = {}
			$scope.opts.current_showing_type = "foo"
		else
			$scope.opts = $cookieStore.get("opts")
		$scope.cached = {}
		$scope.cached.foo = 0
		$scope.cached.bar = "hello, world"
		$scope.cached.foo_list = []
	$scope.send_message = (subject, content) ->
		$scope.bullet.send(JSON.stringify({"subject": subject,"content": content}))
	$scope.init = () ->
		$scope.init_const_and_vars()
		$scope.bullet = $.bullet("ws://" + location.host + "/bullet")
		$scope.bullet.onopen = () ->
			console.log("bullet: connected")
		$scope.bullet.ondisconnect = () ->
			console.log("bullet: disconnected")
		$scope.bullet.onclose = () ->
			console.log("bullet: closed")
		$scope.bullet.onheartbeat = () ->
			$scope.send_message("ping","nil")
		$interval( $cookieStore.put("opts", $scope.opts) , 3000, [], [])
		$scope.bullet.onmessage = (e) ->
			mess = $.parseJSON(e.data)
			subject = mess.subject
			content = mess.content
			if subject == "error" 
				$.growl.error({ message: content , duration: 20000})
			else if subject == "warn"
				$.growl.warning({ message: content , duration: 20000})
			else if subject == "notice"
				$.growl.notice({ message: content , duration: 20000})
			else if subject == "pong"
				"ok"
			#
			#	handle messages from server
			#
			else if subject == "foo"
				$scope.cached.foo_list.push content
			else
				alert "Unexpected message = "+e.data
web_interface.controller(controllers)