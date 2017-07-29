# Commerce.com
A little web app for selling stuff on the Internet!

## How to Run
You will need the Visual Studio with the dotnet stuff.  This is an ASP.NET Core application that targets the Windows .NET platform.  For reasons that I cannot explain, when I clone this repo afresh the Visual Studio solution defaults to the "Debug_Ubuntu" configuration.  If the same thing happens to you, you will want to switch to the Debug configuration.

Also, you will have to install [RabbitMQ](http://www.rabbitmq.com/download.html).  For me, this meant I also had to install Erlang.  Don't know how I feel about Erlang (never used it), but I know Rabbit is popular, so I just installed it.

## Why'd I build this Thing?
I wanted to learn more about messaging as it pertains to microservices.  I maintain a megalithic (like monolothic, only times 10!) desktop application at my job, so I am exceedingly curious about applications that are the opposite of megalithic.

## What kinda technologies were used to build this Thing?
RabbitMQ, of course.  And web sockets.  Courtesy of [websocket-sharp](https://github.com/sta/websocket-sharp).  And Elm!  Love me some Elm!

When you run the application your browser should open to a page that is divided into four rectangles.  In the spirit of microservices, each rectangle is meant to be its own free-standing app.  The rectangles do not communicate with each other in the browser (via javascript).  They communicate only with servers.  They send and receive data only via http requests and web sockets.
