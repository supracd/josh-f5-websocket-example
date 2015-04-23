<!doctype html>

<head>
    <meta charset="utf-8" />
    <title>F5 Status Checker</title>

    <style>
        li {
            list-style: none;
        }
        button.true {
            color: green;
        }
        button.false {
            color: red;
        }
    </style>

    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"></script>
    <script>
        $(document).ready(function() {
            if (!window.WebSocket) {
                if (window.MozWebSocket) {
                    window.WebSocket = window.MozWebSocket;
                } else {
                    $('#pool-stats').append("<li>Your browser doesn't support WebSockets.</li>");
                }
            }
            ws = new WebSocket('ws://127.0.0.1:9000/websocket');
            ws.onopen = function(evt) {};
            ws.onmessage = function(evt) {
                $('#pool-stats').html('');
                var obj = JSON.parse(evt.data);
								console.log(evt.data);
                $.each(obj, function(i, v) {
										v = JSON.parse(v);
                    $('#pool-stats').append($('<button></button>')
                        .attr('class', v.status)
                        .attr('name', v.poolname)
                        .html(v.poolname).click(function() {
                            ws.send($(this).attr('name'));
                        }));
                });
            };
            $('#send-message').submit(function() {
                ws.send($('#pool').val() + ": " + $('#message').val());
                $('#message').val('').focus();
                return false;
            });
        });
    </script>
</head>

<body>
    <h2>F5 Control Interface</h2>
    <div id="pool-stats"></div>
</body>

</html>