require 'rails_helper'

RSpec.describe "Referrals", type: :request do
  before :each do
    Event.destroy_all
    Referral.destroy_all
    Contact.destroy_all
  end

  after :each do
    Event.destroy_all
    Referral.destroy_all
    Contact.destroy_all
  end

  context "GET /index" do
    context "when no param is passed" do
      it "returns a list of all referrals with contact" do
        create_list(:referral, 5)
        expected_result = Referral.all.to_json(include: { contact: { only: [:name, :email, :address] } }, except: :contact_id)

        get "/referral"

        expect(response.body).to eq expected_result
        expect(response).to have_http_status(:success)
      end

      context "when there is no referral in db" do
        it "returns an empty array" do
          Referral.destroy_all

          expected_result = [].to_json

          get "/referral"

          expect(response.body).to eq expected_result
          expect(response).to have_http_status(:success)
        end
      end
    end

    context "when a param is passed" do
      context "when a name is passed as param to search" do
        it "returns only referrals that matchers with param name" do
          expected_result = create_list(:referral, 1)

          get "/referral", :params => { :name => expected_result[0].name }

          expect(response.body).to eq expected_result.to_json(include: { contact: { only: [:name, :email, :address] } }, except: :contact_id)
          expect(response).to have_http_status(:success)
        end
      end

      context "when an email is passed as param to search" do
        it "returns only referrals that matchers with param name" do
          expected_result = create_list(:referral, 1)

          get "/referral", :params => { :email => expected_result[0].email }

          expect(response.body).to eq expected_result.to_json(include: { contact: { only: [:name, :email, :address] } }, except: :contact_id)
          expect(response).to have_http_status(:success)
        end
      end

      context "when an contact_id is passed as param to search" do
        it "returns only referrals that matchers with param name" do
          expected_result = create_list(:referral, 1)

          get "/referral", :params => { :contact_id => expected_result[0].contact_id }

          expect(response.body).to eq expected_result.to_json(include: { contact: { only: [:name, :email, :address] } }, except: :contact_id)
          expect(response).to have_http_status(:success)
        end
      end

      context "when an order config is passed as param to search" do
        context "when an order specification is not passed as param to search" do
          it "returns all referrals ordered as param" do
            expected_result = create_list(:referral, 5).sort_by(&:name)

            get "/referral", :params => { :order_by => 'name' }

            expect(response.body).to eq expected_result.to_json(include: { contact: { only: [:name, :email, :address] } }, except: :contact_id)
            expect(response).to have_http_status(:success)
          end
        end

        context "when an order specification is passed as param to search" do
          it "returns all referrals ordered as param" do
            expected_result = create_list(:referral, 5).sort_by(&:name).reverse

            get "/referral", :params => { :order_by => 'name' , :specify_order => 'desc'}

            expect(response.body).to eq expected_result.to_json(include: { contact: { only: [:name, :email, :address] } }, except: :contact_id)
            expect(response).to have_http_status(:success)
          end
        end
      end

      context "when a pagination config is passed as param to search" do
        context "when only page num is passed" do
          it "returns only one referral per page from second page num as default is one" do
            all_referrals = create_list(:referral, 5)
            expected_result = [all_referrals[1]]

            get "/referral", :params => { :page_num => 2 }

            expect(response.body).to eq expected_result.to_json(include: { contact: { only: [:name, :email, :address] } }, except: :contact_id)
            expect(response).to have_http_status(:success)
          end
        end

        context "when only per page is passed" do
          it "returns two referral from first page num as default is one" do
            all_referrals = create_list(:referral, 5)
            expected_result = [all_referrals[0], all_referrals[1]]

            get "/referral", :params => { :per_page => 2 }

            expect(response.body).to eq expected_result.to_json(include: { contact: { only: [:name, :email, :address] } }, except: :contact_id)
            expect(response).to have_http_status(:success)
          end
        end

        context "when both page num and per page is passed" do
          it "returns two referral per page from the seconde page num" do
            all_referrals = create_list(:referral, 5)
            expected_result = [all_referrals[2], all_referrals[3]]

            get "/referral", :params => { :page_num => 2, :per_page => 2 }

            expect(response.body).to eq expected_result.to_json(include: { contact: { only: [:name, :email, :address] } }, except: :contact_id)
            expect(response).to have_http_status(:success)
          end
        end
      end

      context "when ordered and pagination param is passed" do
        it "return a list of referral ordered and paginated" do
          all_referrals = create_list(:referral, 5).sort_by(&:name).reverse
          expected_result = [all_referrals[2], all_referrals[3]]

          get "/referral", :params => { :order_by => 'name', :specify_order => 'desc' , :page_num =>2, :per_page => 2 }

          expect(response.body).to eq expected_result.to_json(include: { contact: { only: [:name, :email, :address] } }, except: :contact_id)
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  context "GET /show" do
    it "returns http success" do
      expected_result = create(:referral)

      get "/referral/#{expected_result.id}"

      expect(response.body).to eq expected_result.to_json(include: { contact: { only: [:name, :email, :address] } }, except: :contact_id)
      expect(response).to have_http_status(:success)
    end
  end

  context "POST /create" do
    context "when all parameters are all right" do
      it "returns http success" do
        contact = create(:contact)

        post "/referral", :params => { :name => 'Leleo', :email => 'leo@me.com', :contact_id => contact.id}

        expected_result = Referral.find_by(name: 'Leleo', email: 'leo@me.com', contact_id: contact.id)

        expect(response.body).to eq expected_result.to_json(include: { contact: { only: [:name, :email, :address] } }, except: :contact_id)
        expect(response).to have_http_status(:success)
      end
    end
  end

  context "GET /destroy" do
    it "returns http success" do
      contact = create(:contact)
      referral = create(:referral, contact_id: contact.id)

      delete "/referral/#{referral.id}"

      expected_referral = Referral.exists?(id: referral.id)
      expected_contact = Contact.find(contact.id)

      expect(expected_referral).to be false
      expect(expected_contact).to eq contact
      expect(response).to have_http_status(:success)
    end
  end
end
