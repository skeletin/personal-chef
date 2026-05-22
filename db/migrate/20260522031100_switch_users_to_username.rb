# frozen_string_literal: true

class SwitchUsersToUsername < ActiveRecord::Migration[8.1]
  class MigrationUser < ApplicationRecord
    self.table_name = "users"
  end

  def up
    add_column :users, :username, :string

    MigrationUser.reset_column_information
    rows = MigrationUser.all.to_a

    rows.each do |user|
      username = rows.size == 1 ? "admin" : "user_#{user.id}"
      user.update_column(:username, username)
    end

    change_column_null :users, :username, false
    add_index :users, :username, unique: true

    remove_index :users, column: :email_address
    remove_column :users, :email_address
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Automated restore of email_address from username is not supported"
  end
end
