require 'rails_helper'

describe 'navigate index' do
	it 'can reach the categories view' do
		visit categories_path
		expect(page.status_code).to eq(200)
	end

	it 'can create a category if the user is admin' do
		@admin = FactoryGirl.create(:admin_user)
		login_as(@admin)

		visit new_category_path
		expect(page.status_code).to eq(200)

		click_on("category-new-link")
		fill_in	"category[name]", with: "Technology"
		click_on("btn-new-category")
		
		expect(page).to have_content("The category was created successfully.")
		expect(page).to have_content("Technology")
		expect(current_path).to eq(categories_path)
	end

	it 'cannot create a user a regular user' do
		@user = FactoryGirl.create(:user)
		login_as(@user)

		visit new_category_path
		expect(current_path).to eq(root_path)
		expect(page).to have_content("You are not authorized to perform this action.")
	end

	it 'the category has a count of products' do
		user = FactoryGirl.create(:user)
		category = FactoryGirl.create(:technology)
		product1 =  FactoryGirl.create(:product, user_id: user.id, category_id: category.id)
		product2 =  FactoryGirl.create(:product_two, user_id: user.id, category_id: category.id)

		visit categories_path
		expect(page).to have_content("2 products in this category.")
	end


	it 'an admin is available to see the edit and delete actions' do
		@category = FactoryGirl.create(:technology)
		@admin = FactoryGirl.create(:admin_user)
		login_as(@admin)

		visit categories_path
		expect(page).to have_link("edit_#{@category.id}_category")
		expect(page).to have_link("delete_#{@category.id}_category")
	end

	it 'an regular user cannot see the edit and delete actions' do
		@category = FactoryGirl.create(:technology)
		@user = FactoryGirl.create(:user)
		login_as(@user)

		visit categories_path
		expect(page).to_not have_link("edit_#{@category.id}_category")
		expect(page).to_not	have_link("delete_#{@category.id}_category")
	end
end

describe 'navigate show' do
	before do
		@user = FactoryGirl.create(:user)
		@category = FactoryGirl.create(:technology)
		@product1 =  FactoryGirl.create(:product_with_short_description, user_id: @user.id, category_id: @category.id)
		@product2 =  FactoryGirl.create(:product_with_long_description, user_id: @user.id, category_id: @category.id)

		visit categories_path
	end
	
	it 'can reach the show view with some products' do
		visit categories_path
		expect(page.status_code).to eq(200)

		#Testing with pure text
		click_on("category_#{@category.id}_show")
		expect(page).to have_content("Technology")
		expect(page).to have_content("2 products in this category.")
		expect(page).to have_content(450.00)

		expect(page).to have_content("Television Samsung 30 Inches 4k")
		expect(page).to have_content("The best tv in the market")

		#Testing with instances variables and eq
		expect(@product2.name).to eq("Iphone 7 Plus")
		expect(@product2.summary).to eq("Smartphone with the latest technology")
		expect(@product2.price).to eq(350.00)
		@product2.descriptions.each do |description|
			expect(description.name).to eq("[\"Excellent Status 10 of 10\", \"The most coolest phone\", \"Liberated for any carrier\"]")
		end
	end
end

describe "navigate edit" do
	before do
		@category = FactoryGirl.create(:technology)
	end
	
	it 'cannot edit a category if you are not the admin' do
		@regular_user = FactoryGirl.create(:other_user)
		login_as(@regular_user)

		visit edit_category_path(@category)
		expect(current_path).to eq(root_path)
		expect(page).to have_content("You are not authorized to perform this action.")
	end

	it 'can edit a category id admin' do
		@admin = FactoryGirl.create(:admin_user)
		login_as(@admin)

		visit categories_path
		expect(page.status_code).to eq(200)

		click_on("edit_#{@category.id}_category")
		expect(current_path).to eq(edit_category_path(@category))

		fill_in "category[name]", with: "Music"
		fill_in "category[color]", with: "#f39c12"

		click_on("Update The Category")
		expect(current_path).to eq(category_path(@category))
		expect(page).to have_content("Music")
	end
end

describe "navigate create" do
	it 'only an admin can create a category' do
		@admin = FactoryGirl.create(:admin_user)
		login_as(@admin)
		visit new_category_path

		fill_in "category[name]", with: "Office"
		fill_in "category[color]", with: "#fff"
		click_on("Create A Category")

		expect(current_path).to eq(categories_path)
		expect(page).to have_content("The category was created successfully.")
		expect(page).to have_content("Office")
	end

	it 'a regular user cannot create a category' do
		@user = FactoryGirl.create(:user)
		login_as(@user)

		visit new_category_path
		expect(current_path).to eq(root_path)
		expect(page).to have_content("You are not authorized to perform this action.")
	end
end