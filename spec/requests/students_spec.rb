# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Students API', type: :request do
  let(:user) { create(:user) }
  let(:students) { create_list(:student, 10, user_id: user.id) }
  # authorize request
  let(:headers) { valid_headers(user) }

  describe 'GET /students' do
    # update request with headers
    before { get '/students', params: {}, headers: headers }
    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /students/{}' do
    before { get "/students/#{students.first.id}", params: {}, headers: headers }
    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /students' do
    context 'when valid request' do
      before { post '/students', params: student_params, headers: headers }
      it 'return status code 201' do
        expect(response).to have_http_status(201) # 201 => :created
      end
    end

    context 'when invalid request' do
      before { post '/students', params: { student: { name: 'Paul' } }.to_json, headers: headers }
      it 'return status code 422' do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PUT /students' do
    context 'when valid request' do
      before do
        put "/students/#{students.first.id}",
            params: { institution: 'Home' }.to_json, headers: headers
      end
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when invalid request' do
      before do
        put "/students/#{students.first.id}",
            params: { institution: '' }.to_json, headers: headers
      end
      it 'returns status code 200' do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE /students' do
    before do
      delete "/students/#{students.first.id}", headers: headers
    end
    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /students/inactive' do
    let(:user) { User.create(name: 'Test User', email: 'test@example.com', password: 'password') }
    let(:headers) { { 'Authorization' => token_generator(user.id), 'Content-Type' => 'application/json' } }
    
    before do
      # Create institution first
      institution = Institution.create!(name: 'Test Institution')
      
      # Create test data directly
      Student.create!(
        name: 'Active Student',
        email: 'active@example.com',
        mobile_number: '1234567890',
        instruments: 'Piano',
        user_id: user.id,
        institution_id: institution.id,
        status: :active
      )
      Student.create!(
        name: 'Inactive Student 1',
        email: 'inactive1@example.com',
        mobile_number: '1234567891',
        instruments: 'Guitar',
        user_id: user.id,
        institution_id: institution.id,
        status: :inactive
      )
      Student.create!(
        name: 'Inactive Student 2',
        email: 'inactive2@example.com',
        mobile_number: '1234567892',
        instruments: 'Violin',
        user_id: user.id,
        institution_id: institution.id,
        status: :inactive
      )
    end

    it 'returns status code 200' do
      get '/students/inactive', params: {}, headers: headers
      expect(response).to have_http_status(200)
    end

    it 'returns only inactive students with institution information' do
      get '/students/inactive', params: {}, headers: headers
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(2)
      expect(json_response.map { |student| student['status'] }).to all(eq('inactive'))
      expect(json_response.first['institution']).to include('name')
      expect(json_response.first['institution']['name']).to eq('Test Institution')
    end
  end

  private

  def student_params
    { student: {
      name: 'Paul',
      institution: 'KCM',
      instrument: 'Violin',
      mobile_number: '0715987334'
    } }.to_json
  end
end
