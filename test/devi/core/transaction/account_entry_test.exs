defmodule Devi.Core.AccountEntryTest do
  use ExUnit.Case, async: true
  alias Devi.Core.AccountEntry

  setup do
    %{now: DateTime.from_iso8601("2022-03-03T23:50:07Z") |> elem(1)}
  end

  describe "new/1" do
    test "allows all parent_account_type", %{now: now} do
      result =
        AccountEntry.new(%{account: {:asset, "any"}, amount: 1, type: :increase, inserted_at: now})

      assert result == %AccountEntry{
               account: {:asset, "any"},
               amount: 1,
               type: :increase,
               inserted_at: now
             }

      result =
        AccountEntry.new(%{
          account: {:capital, "any"},
          amount: 1,
          type: :increase,
          inserted_at: now
        })

      assert result == %AccountEntry{
               account: {:capital, "any"},
               amount: 1,
               type: :increase,
               inserted_at: now
             }

      result =
        AccountEntry.new(%{
          account: {:dividend, "any"},
          amount: 1,
          type: :increase,
          inserted_at: now
        })

      assert result == %AccountEntry{
               account: {:dividend, "any"},
               amount: 1,
               type: :increase,
               inserted_at: now
             }

      result =
        AccountEntry.new(%{
          account: {:expense, "any"},
          amount: 1,
          type: :increase,
          inserted_at: now
        })

      assert result == %AccountEntry{
               account: {:expense, "any"},
               amount: 1,
               type: :increase,
               inserted_at: now
             }

      result =
        AccountEntry.new(%{
          account: {:liability, "any"},
          amount: 1,
          type: :increase,
          inserted_at: now
        })

      assert result == %AccountEntry{
               account: {:liability, "any"},
               amount: 1,
               type: :increase,
               inserted_at: now
             }

      result =
        AccountEntry.new(%{
          account: {:revenue, "any"},
          amount: 1,
          type: :increase,
          inserted_at: now
        })

      assert result == %AccountEntry{
               account: {:revenue, "any"},
               amount: 1,
               type: :increase,
               inserted_at: now
             }
    end

    test "Will reject other parent account types", %{now: now} do
      assert_raise ArgumentError, fn ->
        AccountEntry.new(%{
          account: {:anything_else, "any"},
          amount: 1,
          type: :increase,
          inserted_at: now
        })
      end
    end

    test "Will reject bad account entry types", %{now: now} do
      assert_raise ArgumentError, fn ->
        AccountEntry.new(%{
          account: {:asset, "any"},
          amount: 1,
          type: :not_increase_or_decrease,
          inserted_at: now
        })
      end
    end
  end

  describe "subtotal/1" do
    test "Reduces a list of changes to a subtotal value", %{now: now} do
      entries = [
        AccountEntry.new(%{account: {:asset, "any"}, amount: 5, type: :increase, inserted_at: now}),
        AccountEntry.new(%{account: {:asset, "any"}, amount: 6, type: :increase, inserted_at: now}),
        AccountEntry.new(%{account: {:asset, "any"}, amount: 2, type: :decrease, inserted_at: now}),
        AccountEntry.new(%{account: {:asset, "any"}, amount: 1, type: :decrease, inserted_at: now})
      ]

      assert AccountEntry.subtotal(entries) == 8
    end
  end

  describe "subtotal/2" do
    test "Reduces a list of changes and a default value to a subtotal value", %{now: now} do
      entries = [
        AccountEntry.new(%{account: {:asset, "any"}, amount: 5, type: :increase, inserted_at: now}),
        AccountEntry.new(%{account: {:asset, "any"}, amount: 6, type: :increase, inserted_at: now}),
        AccountEntry.new(%{account: {:asset, "any"}, amount: 2, type: :decrease, inserted_at: now}),
        AccountEntry.new(%{account: {:asset, "any"}, amount: 1, type: :decrease, inserted_at: now})
      ]

      assert AccountEntry.subtotal(entries, 10) == 18
    end
  end
end
