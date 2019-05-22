Sequel.migration do
  change do
    create_table(:users) do
      column :id, 'character varying', primary_key: true
      column :email, 'character varying', null: false, unique: true
    end
  end
end
