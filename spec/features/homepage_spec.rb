require 'rails_helper'

describe 'navigate' do
	describe 'homepage' do
		before do
			visit root_path
		end

		it "can be reached successfully" do
			expect(page.status_code).to eq(200)
		end

		it "can have content" do
			expect(page).to have_content("Sunday Market!")
			expect(page).to have_content("Shops")
			expect(page).to have_content("Products")
			expect(page).to have_content("Categories")
		end
	end
end