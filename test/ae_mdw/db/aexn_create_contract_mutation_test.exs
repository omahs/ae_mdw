defmodule AeMdw.Db.AexnCreateContractMutationTest do
  use AeMdw.Db.MutationCase, async: false

  alias AeMdw.Db.AexnCreateContractMutation
  alias AeMdw.Db.Model
  alias AeMdw.Stats
  alias AeMdw.Validate

  require Model

  import Mock
  import AeMdw.TestUtil, only: [change_store: 2]

  describe "execute" do
    test "successful for aex9 contract", %{store: store} do
      contract_pk = :crypto.strong_rand_bytes(32)
      aex9_meta_info = {name, symbol, _decimals} = {"911058", "SPH", 18}
      {kbi, mbi} = block_index = {Enum.random(1..999_999), 99}
      next_height = kbi + 1
      create_txi = txi = 12_361_891
      extensions = ["ext1"]

      kb_hash = :crypto.strong_rand_bytes(32)
      next_hash = :crypto.strong_rand_bytes(32)

      with_mocks [
        {AeMdw.Node.Db, [:passthrough],
         [
           get_key_block_hash: fn ^next_height -> kb_hash end,
           get_next_hash: fn ^kb_hash, ^mbi -> next_hash end,
           aex9_balance: fn ^contract_pk, {:micro, ^kbi, ^next_hash} -> {:ok, %{}} end
         ]}
      ] do
        store =
          change_store(store, [
            AexnCreateContractMutation.new(
              :aex9,
              contract_pk,
              aex9_meta_info,
              block_index,
              create_txi,
              extensions
            )
          ])

        m_contract_pk =
          Model.aexn_contract(
            index: {:aex9, contract_pk},
            txi: txi,
            meta_info: aex9_meta_info,
            extensions: extensions
          )

        assert {:ok, ^m_contract_pk} = Store.get(store, Model.AexnContract, {:aex9, contract_pk})

        assert {:ok, Model.stat(payload: 1)} =
                 Store.get(store, Model.Stat, Stats.aexn_count_key(:aex9))

        refute :not_found == Store.get(store, Model.AexnContractName, {:aex9, name, contract_pk})

        refute :not_found ==
                 Store.get(store, Model.AexnContractSymbol, {:aex9, symbol, contract_pk})
      end
    end

    test "indexes with full meta_info and truncates aex9 name sort field", %{store: store} do
      contract_pk = Validate.id!("ct_2i9DXGKP1VPBJis1YaXihXPtma2tVhsrvZ1jrnFtGNtLh6CYqD")
      bigger_name = String.duplicate("123", 34)
      truncated_name = String.slice(bigger_name, 0, 100) <> "..."
      symbol = "SPH2"
      aex9_meta_info = {bigger_name, symbol, 18}
      {kbi, mbi} = block_index = {271_305, 99}
      next_height = kbi + 1
      create_txi = txi = 12_361_891
      extensions = ["ext1"]

      kb_hash = :crypto.strong_rand_bytes(32)
      next_hash = :crypto.strong_rand_bytes(32)

      with_mocks [
        {AeMdw.Node.Db, [:passthrough],
         [
           get_key_block_hash: fn ^next_height -> kb_hash end,
           get_next_hash: fn ^kb_hash, ^mbi -> next_hash end,
           aex9_balance: fn ^contract_pk, {:micro, ^kbi, ^next_hash} -> {:ok, %{}} end
         ]}
      ] do
        store =
          change_store(store, [
            AexnCreateContractMutation.new(
              :aex9,
              contract_pk,
              aex9_meta_info,
              block_index,
              create_txi,
              extensions
            )
          ])

        m_contract_pk =
          Model.aexn_contract(
            index: {:aex9, contract_pk},
            txi: txi,
            meta_info: aex9_meta_info,
            extensions: extensions
          )

        assert {:ok, Model.stat(payload: 1)} =
                 Store.get(store, Model.Stat, Stats.aexn_count_key(:aex9))

        assert {:ok, ^m_contract_pk} = Store.get(store, Model.AexnContract, {:aex9, contract_pk})

        refute :not_found ==
                 Store.get(store, Model.AexnContractName, {:aex9, truncated_name, contract_pk})

        refute :not_found ==
                 Store.get(store, Model.AexnContractSymbol, {:aex9, symbol, contract_pk})
      end
    end

    test "successful for aex141 contract", %{store: store} do
      contract_pk = Validate.id!("ct_2ZpMr6PfL1XzgWosguyUtgr9b2kKeqqGQpwSeXzT28j7f8LJH5")

      aex141_meta_info =
        {name, symbol, _base_url, _type} = {"prenft2", "PNFT2", "some-fake-url", :url}

      extensions = ["ext1", "ext2"]
      block_index = {610_470, 77}
      create_txi = txi = 28_522_602

      store =
        change_store(store, [
          AexnCreateContractMutation.new(
            :aex141,
            contract_pk,
            aex141_meta_info,
            block_index,
            create_txi,
            extensions
          )
        ])

      m_contract_pk =
        Model.aexn_contract(
          index: {:aex141, contract_pk},
          txi: txi,
          meta_info: aex141_meta_info,
          extensions: extensions
        )

      assert {:ok, Model.stat(payload: 1)} =
               Store.get(store, Model.Stat, Stats.aexn_count_key(:aex141))

      assert {:ok, ^m_contract_pk} = Store.get(store, Model.AexnContract, {:aex141, contract_pk})
      refute :not_found == Store.get(store, Model.AexnContractName, {:aex141, name, contract_pk})

      refute :not_found ==
               Store.get(store, Model.AexnContractSymbol, {:aex141, symbol, contract_pk})
    end

    test "indexes with full meta_info and truncates aex141 symbol sort field", %{store: store} do
      contract_pk = Validate.id!("ct_2ZpMr6PfL1XzgWosguyUtgr9b2kKeqqGQpwSeXzT28j7f8LJH5")
      bigger_symbol = "PNFT" <> String.duplicate("123", 33)
      truncated_symbol = String.slice(bigger_symbol, 0, 100) <> "..."
      name = "prenft2"
      aex141_meta_info = {name, bigger_symbol, "http://some-fake-url.com", :url}

      extensions = ["ext1", "ext2"]
      block_index = {610_470, 77}
      create_txi = txi = 28_522_602

      store =
        change_store(store, [
          AexnCreateContractMutation.new(
            :aex141,
            contract_pk,
            aex141_meta_info,
            block_index,
            create_txi,
            extensions
          )
        ])

      m_contract_pk =
        Model.aexn_contract(
          index: {:aex141, contract_pk},
          txi: txi,
          meta_info: aex141_meta_info,
          extensions: extensions
        )

      assert {:ok, Model.stat(payload: 1)} =
               Store.get(store, Model.Stat, Stats.aexn_count_key(:aex141))

      assert {:ok, ^m_contract_pk} = Store.get(store, Model.AexnContract, {:aex141, contract_pk})
      refute :not_found == Store.get(store, Model.AexnContractName, {:aex141, name, contract_pk})

      refute :not_found ==
               Store.get(
                 store,
                 Model.AexnContractSymbol,
                 {:aex141, truncated_symbol, contract_pk}
               )
    end

    test "indexes aex141 with error meta_info without sorting records", %{store: store} do
      contract_pk = Validate.id!("ct_ukZe6BBpuSWxT8hxd87z11vdgRnwKnedEWqJ7SyQucbX1C1pc")
      aex141_meta_info = {:format_error, :format_error, :format_error, nil}

      extensions = ["ext1", "ext2"]
      block_index = {610_470, 77}
      create_txi = txi = 28_522_602

      store =
        change_store(store, [
          AexnCreateContractMutation.new(
            :aex141,
            contract_pk,
            aex141_meta_info,
            block_index,
            create_txi,
            extensions
          )
        ])

      m_contract_pk =
        Model.aexn_contract(
          index: {:aex141, contract_pk},
          txi: txi,
          meta_info: aex141_meta_info,
          extensions: extensions
        )

      assert :not_found == Store.get(store, Model.Stat, Stats.aexn_count_key(:aex141))

      assert {:ok, ^m_contract_pk} = Store.get(store, Model.AexnContract, {:aex141, contract_pk})

      assert :not_found ==
               Store.get(
                 store,
                 Model.AexnContractName,
                 {:aex141, :format_error, contract_pk}
               )

      assert :not_found ==
               Store.get(
                 store,
                 Model.AexnContractSymbol,
                 {:aex141, :format_error, contract_pk}
               )
    end
  end
end
