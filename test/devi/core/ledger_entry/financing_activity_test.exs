defmodule Devi.Core.LedgerEntry.FinancingActivityTest do
  use ExUnit.Case, async: true
  alias Devi.Core.LedgerEntry

  setup do
    %{now: "2022-03-03T23:50:07Z" |> DateTime.from_iso8601() |> elem(1)}
  end

  describe "receive_capital/1" do
    test "generates ledger entries", %{now: now} do
      capital_account = %{type: :capital, id: :mac_capital}
      asset_account = %{type: :asset, id: :cash}
      amount = 500

      {activity_tag, entries} =
        LedgerEntry.receive_capital(%{
          capital_account: capital_account,
          asset_account: asset_account,
          amount: amount,
          inserted_at: now
        })

      assert activity_tag == :financing
      assert Enum.count(entries) == 2

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: asset_account,
                 amount: amount,
                 inserted_at: now,
                 type: :increase
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: capital_account,
                 amount: amount,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end

  describe "pay_dividend/1" do
    test "generates ledger entries", %{now: now} do
      asset_account = %{type: :asset, id: :cash}
      dividend_account = %{type: :dividend, id: :mac_dividend}
      amount = 500

      {activity_tag, entries} =
        LedgerEntry.pay_dividend(%{
          asset_account: asset_account,
          dividend_account: dividend_account,
          amount: amount,
          inserted_at: now
        })

      assert activity_tag == :financing
      assert Enum.count(entries) == 2

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: asset_account,
                 amount: amount,
                 inserted_at: now,
                 type: :decrease
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: dividend_account,
                 amount: amount,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end
end
