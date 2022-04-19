defmodule Devi.Core.GeneralLedger.AccountTest do
  use ExUnit.Case, async: true

  alias Devi.Core

  describe "account_types/0" do
    test "returns the available account types" do
      assert Core.account_types() == ~w[asset capital dividend expense liability revenue]a
    end
  end
end
