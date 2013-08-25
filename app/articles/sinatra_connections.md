$title: Sinatra Connections
$author: Max
$tags: sinatra, api, technical, bug
$published: true

##The Prelude

Recently I&#39;ve been involved in creating an api with no human-intended view
part.  Given the apparent simplicity of such a build we made the decision to
rock with Sinatra. After all it provided support for all the required verbs,
can work with activerecord and makes getting the app started silly fast.

##In the Beginning

Things went smoothly, sure there was the occasional re-implementation of a
standard piece of activesupport functionality, but overall it was easy to
manage. Oh, there was one other pain in the backside which was the use of the
sinatra namespacing gem as its DSL uses the same function name as Rake.
Nevertheless we forged on, knowing that by not using rails we&#39;d taken the
sensible approach of not filling the app with uneeded functionality.

##The Monster Under the Bed

The api went down, as did the app upon which it depends. Digging into the logs
only revealed that one of the dynos had timed-out. A quick restart and things
were once again fine. However the api no longer felt safe, it felt fragile and
dangerous, like a tower of glass ready to shatter and shred everything that had
grown to depend on it. Sure enough it went down again, and then again, and once
more (probably for good measure more than actual need). It was always the same
dyno that was failing and this raised the obvious suspicion of a faulty
instance so a quick support request was fired off to Heroku. The reply
indicated that it would be looked into but could we, in the meantime, add the
rack-timeout gem. This proved to be an excellent idea.

##The Villian Revealed

Timeouts continued to occur, but this time under the watchful gaze of the
rack-timeout gem. This provided a stacktrace showing exactly where the api was
taking longer than 15 seconds to complete. 

~~~
STACKTRACE
~~~

