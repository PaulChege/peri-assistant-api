# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Users API', type: :request do
  let(:user) { create(:user) }
  let(:headers) { valid_headers.except('Authorization') }
  
  # User signup test suite
  describe 'POST /signup' do
    context 'when valid request' do
      before { post '/signup', params: user_params, headers: headers }

      it 'creates a new user' do
        expect(response).to have_http_status(200)
      end

      it 'returns success message' do
        expect(json['message']).to match(/Account created successfully/)
      end

      it 'returns an authentication token' do
        expect(json['token']).not_to be_nil
      end
    end

    context 'when invalid request' do
      before { post '/signup', params: {user: {name: ""}}.to_json, headers: headers }

      it 'does not create a new user' do
        expect(response).to have_http_status(422)
      end

      it 'returns failure message' do
        expect(json['message'])
          .to match(/Password can't be blank, Name can't be blank, Email can't be blank, Password digest can't be blank/)
      end
    end
  end



    let(:headers) { valid_headers }

    # User update test suite
    describe 'PUT /users/:id' do
      context 'when valid request' do
        before do 
           put "/users/#{user.id}", params: {user: {name: "Jane"}}.to_json, headers: headers 
        end
  
        it 'updates user details' do
          expect(response).to have_http_status(200)
        end
  
      end
  
      context 'when invalid request' do
        before { put "/users/#{user.id}", params: {user: {name: ""}}.to_json, headers: headers }
  
        it 'does not update user detailsxs' do
          expect(response).to have_http_status(422)
        end
  
        it 'returns failure message' do
          expect(json['message'])
            .to match(/Name can't be blank/)
        end
      end
    end


    describe "DELETE /users/:id" do
      before do
        delete "/users/#{user.id}", headers: headers
      end

      it "deletes a user" do
        expect(response).to have_http_status(200)
      end
    end

  private
  def user_params
    {
      user: {
        name: "Paul",
        email: "paul@gmail.com",
        password: "password",
        password_confirmation: "password"
      }
    }.to_json
  end
end
