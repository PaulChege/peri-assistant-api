RSpec.describe 'Students API', type: :request do
    # add todos owner
    let(:user) { create(:user) }
    let!(:students) { create_list(:student, 10, user_id: user.id) }
    let(:student_id) { students.first.id }
    # authorize request
    let(:headers) { valid_headers }
  
    describe 'GET /students' do
      # update request with headers
      before { get '/students', params: {}, headers: headers }
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
end