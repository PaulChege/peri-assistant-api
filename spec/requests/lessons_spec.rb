# frozen_string_literal: true

RSpec.describe 'Lessons API', type: :request do
  # add todos owner
  let(:user) { create(:user) }
  let(:student) { create(:student, user_id: user.id) }
  let(:lessons) { create_list(:lesson, 10, student_id: student.id) }

  # authorize request
  let(:headers) { valid_headers }

  describe 'GET students/{}/lessons' do
    # update request with headers
    before { get "/students/#{student.id}/lessons", params: {}, headers: headers }
    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /students/{}/lessons/{}' do
    before do
      get "/students/#{student.id}/lessons/#{lessons.first.id}",
          params: {}, headers: headers
    end
    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /students/{}/lessons/' do
    context 'when valid request' do
      before { post "/students/#{student.id}/lessons/", params: lesson_params, headers: headers }
      it 'return status code 201' do
        expect(response).to have_http_status(201) # 201 => :created
      end
    end

    context 'when invalid request' do
      before do
        post "/students/#{student.id}/lessons/", params: { lesson: { day: 'Monday' } }.to_json,
                                                 headers: headers
      end
      it 'return status code 422' do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PUT /students/{}/lessons/' do
    context 'when valid request' do
      before do
        put "/students/#{student.id}/lessons/#{lessons.first.id}",
            params: { time: '13:45' }.to_json, headers: headers
      end
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when invalid request' do
      before do
        put "/students/#{student.id}/lessons/#{lessons.first.id}",
            params: { day: '' }.to_json, headers: headers
      end
      it 'returns status code 200' do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE /students/{}/lessons/{}' do
    before do
      delete "/students/#{student.id}/lessons/#{lessons.first.id}", headers: headers
    end
    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  private

  def lesson_params
    { lesson: {
      day: Date.today,
      time: '12:30',
      duration: 30
    } }.to_json
  end
end
