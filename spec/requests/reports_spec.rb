# frozen_string_literal: true

RSpec.describe 'Reports API', type: :request do
  let(:user) { create(:user) }
  let(:student1) { create(:student, user_id: user.id) }
  let(:student2) { create(:student, user_id: user.id) }
  let(:headers) { valid_headers }

  describe 'GET /reports' do
    let!(:report1) { create(:report, student_id: student1.id) }
    let!(:report2) { create(:report, student_id: student2.id) }

    context 'when no student_id is provided' do
      before { get '/reports', headers: headers }
      
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns all reports for all students of the user' do
        json_response = JSON.parse(response.body)
        expect(json_response['reports'].length).to eq(2)
        expect(json_response['metadata']['user']['id']).to eq(user.id)
      end
    end

    context 'when student_id is provided' do
      before { get '/reports', params: { student_id: student1.id }, headers: headers }
      
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns only reports for the specified student' do
        json_response = JSON.parse(response.body)
        expect(json_response['reports'].length).to eq(1)
        expect(json_response['reports'].first['student']['id']).to eq(student1.id)
        expect(json_response['metadata']['student']['id']).to eq(student1.id)
      end
    end

    context 'with pagination' do
      let!(:reports) { create_list(:report, 15, student_id: student1.id) }

      before { get '/reports', params: { student_id: student1.id, page: 1, per_page: 10 }, headers: headers }
      
      it 'returns paginated results' do
        json_response = JSON.parse(response.body)
        expect(json_response['reports'].length).to eq(10)
        expect(json_response['current_page']).to eq(1)
        expect(json_response['total_pages']).to eq(2)
      end
    end
  end

  describe 'POST /reports' do
    let(:valid_params) do
      {
        student_id: student1.id,
        report: {
          summary: 'Test report',
          start_date: Date.current,
          end_date: Date.current + 1.week
        }
      }.to_json
    end

    before { post '/reports', params: valid_params, headers: headers }
    
    it 'returns status code 201' do
      expect(response).to have_http_status(201)
    end

    it 'creates a new report' do
      expect(Report.count).to eq(1)
    end
  end

  describe 'GET /reports/{id}' do
    let(:report) { create(:report, student_id: student1.id) }

    before { get "/reports/#{report.id}", headers: headers }
    
    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'PUT /reports/{id}' do
    let(:report) { create(:report, student_id: student1.id) }

    before { put "/reports/#{report.id}", params: { report: { summary: 'Updated summary' } }.to_json, headers: headers }
    
    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'DELETE /reports/{id}' do
    let(:report) { create(:report, student_id: student1.id) }

    before { delete "/reports/#{report.id}", headers: headers }
    
    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end

  describe 'POST /reports/generate' do
    let!(:lesson1) { create(:lesson, student_id: student1.id, date_time: Date.current, plan: 'Scales practice', notes: 'Good progress on C major scale') }
    let!(:lesson2) { create(:lesson, student_id: student1.id, date_time: Date.current + 1.day, plan: 'Piece practice', notes: 'Working on Beethoven Sonata') }

    context 'when valid parameters are provided' do
      before do
        post '/reports/generate', params: {
          student_id: student1.id,
          start_date: Date.current.strftime('%Y-%m-%d'),
          end_date: (Date.current + 1.day).strftime('%Y-%m-%d')
        }, headers: headers
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a generated report' do
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('summary')
        expect(json_response).to have_key('lessons_count')
        expect(json_response).to have_key('period')
        expect(json_response['lessons_count']).to eq(2)
      end
    end

    context 'when no lessons are found' do
      before do
        post '/reports/generate', params: {
          student_id: student1.id,
          start_date: (Date.current + 10.days).strftime('%Y-%m-%d'),
          end_date: (Date.current + 15.days).strftime('%Y-%m-%d')
        }, headers: headers
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error message' do
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('No lessons found for the specified period')
      end
    end

    context 'when invalid date format is provided' do
      before do
        post '/reports/generate', params: {
          student_id: student1.id,
          start_date: 'invalid-date',
          end_date: 'invalid-date'
        }, headers: headers
      end

      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end
    end

    context 'when student is not found' do
      before do
        post '/reports/generate', params: {
          student_id: 99999,
          start_date: Date.current.strftime('%Y-%m-%d'),
          end_date: Date.current.strftime('%Y-%m-%d')
        }, headers: headers
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end
end
