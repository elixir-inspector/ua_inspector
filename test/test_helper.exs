Code.require_file("helpers/regexes.exs", __DIR__)
Code.require_file("helpers/test_server.exs", __DIR__)

ExUnit.start()
ExAgent.TestHelper.TestServer.start()
