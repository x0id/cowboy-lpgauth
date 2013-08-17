defmodule ElixirHelloWorld.Mixfile do
  use Mix.Project

  def project do
    [ app: :elixir_hello_world,
      version: "0.0.1",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ mod: { ElixirHelloWorld, [] },
      applications: [:cowboy] ]
  end

  defp deps do
    [ {:barrel,  github: "benoitc/barrel", tag: "2.1"},
      {:cowboy, github: "refuge/cowboy", branch, "barrel"} ]
  end
end
