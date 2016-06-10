defmodule Philter.Router do
  use Philter.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Philter do
    pipe_through :browser

    post "/twiml", TwimlController, :index

  end

  scope "/api", Philter do
    pipe_through :api

    post "/sms", SmsController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Philter do
  #   pipe_through :api
  # end
end
