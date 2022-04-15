defmodule Devi.Core.AccountTest do
  use ExUnit.Case, async: true
  import Devi.CoreFixtures
  alias Devi.Core.Account

  describe "new/1" do
    setup do
      %{
        asset_params: account_attributes(%{type: :asset, id: "any"}),
        capital_params: account_attributes(%{type: :capital, id: "any"}),
        dividend_params: account_attributes(%{type: :dividend, id: "any"}),
        expense_params: account_attributes(%{type: :expense, id: "any"}),
        liability_params: account_attributes(%{type: :liability, id: "any"}),
        revenue_params: account_attributes(%{type: :revenue, id: "any"})
      }
    end

    test "allows asset types", %{asset_params: params} do
      assert %Account{} = Account.new(params)
    end

    test "allows capital types", %{capital_params: params} do
      assert %Account{} = Account.new(params)
    end

    test "allows dividend types", %{dividend_params: params} do
      assert %Account{} = Account.new(params)
    end

    test "allows expense types", %{expense_params: params} do
      assert %Account{} = Account.new(params)
    end

    test "allows liability types", %{liability_params: params} do
      assert %Account{} = Account.new(params)
    end

    test "allows revenue types", %{revenue_params: params} do
      assert %Account{} = Account.new(params)
    end

    test "Will reject other parent account types" do
      assert_raise ArgumentError, fn ->
        %{type: :anything_else}
        |> account_attributes()
        |> Account.new()
      end
    end
  end
end
