ActiveRecord::Schema.define(:version => 1) do
  create_table "postcards", :force => true do |t|
    t.column "title", :string
    t.column "text", :text
  end
  create_table "addresses", :force => true do |t|
    t.column "user_id", :integer
    t.column "street_address_1", :string
    t.column "street_address_2", :string
    t.column "city", :string
    t.column "postcode", :string
    t.column "country", :string
  end
  create_table "users", :force => true do |t|
    t.column "email", :string
    t.column "firstname", :string
    t.column "lastname", :string
    t.column "always_validate_this", :text
  end

end
