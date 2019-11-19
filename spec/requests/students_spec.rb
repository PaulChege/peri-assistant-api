RSpec.describe 'Students API', type: :request do
    # add todos owner
    let(:user) { create(:user) }
    let(:students) { create_list(:student, 10, user_id: user.id) }
    # authorize request
    let(:headers) { valid_headers }
  
    describe 'GET /students' do
      # update request with headers
      before { get '/students', params: {}, headers: headers }
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
    

    describe 'GET /students/{}' do 
      before {get "/students/#{students.first.id}", params: {}, headers: headers}
      it "returns status code 200" do 
        expect(response).to have_http_status(200)
      end
    end

    describe 'POST /students' do 
      context "when valid request" do
        before {post "/students", params: student_params, headers: headers}
        it 'return status code 201' do
          expect(response).to have_http_status(201) # 201 => :created
        end
      end

      context "when invalid request" do
        before {post "/students", params: {student: {name: "Paul"}}.to_json, headers: headers}
        it 'return status code 422' do
          expect(response).to have_http_status(422)
        end
      end
    end

    describe 'PUT /students' do
      context "when valid request" do
      before {
        put "/students/#{students.first.id}", 
          params: {institution: "Home"}.to_json, headers: headers
        }
        it "returns status code 200" do
          expect(response).to have_http_status(200)
        end
      end

      context "when invalid request" do
        before {
          put "/students/#{students.first.id}", 
            params: {institution: ""}.to_json, headers: headers
          }
          it "returns status code 200" do
            expect(response).to have_http_status(422)
          end
      end
    end


    describe 'DELETE /students' do
      before {
        delete "/students/#{students.first.id}", headers: headers
        }
        it "returns status code 200" do
          expect(response).to have_http_status(200)
        end
    end


    private
      def student_params
        { student: {
          name: "Paul",
          institution: "KCM", 
          instrument: "Violin", 
          mobile_number: "0715987334"
          }
        }.to_json
      end
end