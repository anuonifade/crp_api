require 'swagger_helper'

describe 'CRP API' do
  path '/api/v1/signin' do
    post 'Signin user' do
      tags 'Authenticate User'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: ['email', 'password']
      }

      response '200', 'Successfully signed in' do
        examples 'application/json' => {
          email: 'foobar@example.com',
          password: '123456'
        }
        let(:params) {{ 
          email: 'foobar@example.com',
          password: '123456'
        }}
        run_test!
      end

      response '401', 'Invalid Credential' do
        examples 'application/json' => {
          email: 'foobar@example.com'
        }

        let(:params) {{
          email: 'foobar@example.com'
        }}
      end
    end
  end

  path '/api/v1/user' do
    post 'Signup without a referral' do
      tags 'SignUp'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          first_name: { type: :string },
          last_name: { type: :string },
          email: { type: :string },
          password: { type: :string }
        },
        required: ['first_name', 'last_name', 'email', 'password']
      }

      response '201', 'Signup Successful' do 
        examples 'application/json' => {
          first_name: 'Foo',
          last_name: 'Bar',
          email: 'foobar@example.com',
          password: '123456'
        }

        let(:params) {{ 
          first_name: 'Foo',
          last_name: 'Bar',
          email: 'foobar@example.com',
          password: '123456'
        }}
        run_test!
      end

      response '422', 'invalid request' do
        examples 'application/json' => {
          first_name: 'Foo',
          last_name: 'Bar'
        }

        let(:user) {{ 
          first_name: 'Foo',
          last_name: 'Bar'
        }}
        run_test!
      end

      response '500', 'Internal Server error' do
        examples 'application/json' => { error: 'Server Error' }

        let(:params) do
          {}
        end
      end
    end

    get 'Gets currently signed in User' do
      tags 'Fetch User'
      produces 'application/json'
      response '200', 'User found' do 
        examples 'application/json' => {}
        run_test!
      end

      response '401', 'invalid Authentication' do
        examples 'application/json' => {}
        run_test!
      end
    end
  end

  path '/api/v1/signup/{referral_token}' do
    post 'Signup with referral link' do
      tags 'SignUp with a referral link'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :referral_token, in: :path, type: :string
      parameter name: :params, in: :body,
      schema: {
        type: :object,
        properties: {
          first_name: { type: :string },
          last_name: { type: :string },
          email: { type: :string },
          password: { type: :string }
        },
        required: ['first_name', 'last_name', 'email', 'password']
      }

      response '201', 'Signup Successful with $10 reward' do 
        examples 'application/json' => {
          first_name: 'Foo',
          last_name: 'Bar',
          email: 'foobar@example.com',
          password: '123456'
        }
        let(:params) {{ 
          first_name: 'Foo',
          last_name: 'Bar',
          email: 'foobar@example.com',
          password: '123456',
          referral_token: SecureRandom.alphanumeric(16)
        }}
        run_test!
      end

      response '422', 'invalid request' do
        examples 'application/json' => {
          first_name: 'Foo',
          last_name: 'Bar'
        }
        let(:user) {{ 
          first_name: 'Foo',
          last_name: 'Bar'
        }}
        run_test!
      end
    end
  end

  path '/api/v1/referral_link' do
    get 'Get Referral Link' do
      tags 'Get Logged in User referral link'
      produces 'application/json'
      response '200', 'User found' do 
        let(:user) { create(:user_with_referral) }
        let(:Authorization) { "Basic #{{user: user.id}}" }
        examples 'application/json' => {}
        run_test!
      end

      response '401', 'invalid Authentication' do
        let(:Authorization) { "Basic #{{user: 'Invalid'}}" }
        examples 'application/json' => {}
        run_test!
      end
    end
  end

  path '/api/v1/rewards' do
    get 'Get Rewards for logged in User' do
      tags 'Get Rewards'
      produces 'application/json'
      response '200', 'User found' do
        let(:user) { create(:user_with_referral) }
        let(:Authorization) { "Basic #{{user: user.id}}" }
        examples 'application/json' => {}
        run_test!
      end

      response '401', 'invalid Authentication' do
        let(:Authorization) { "Basic #{{user: 'Invalid'}}" }
        examples 'application/json' => {}
        run_test!
      end
    end
  end

  path '/api/v1/referred_users' do
    get 'Get Registered User invited by Logged in user' do
      tags 'Get Invited registered users'
      produces 'application/json'
      response '200', 'User found' do 
        let(:user) { create(:user_with_referral) }
        let(:Authorization) { "Basic #{{user: user.id}}" }
        examples 'application/json' => {}
        run_test!
      end

      response '401', 'invalid Authentication' do
        let(:Authorization) { "Basic #{{user: 'Invalid'}}" }
        examples 'application/json' => {}
        run_test!
      end
    end
  end

  path '/api/v1/invite' do
    post 'Sends referral invitation to emails' do
      tags 'Send invite to Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :params, in: :body,
      schema: {
        type: :object,
        properties: {
          emails: {
            type: :array,
            description: "emails of users to invite",
            items: { type: :string }
          }
        },
        required: ['emails']
      }

      response '200', 'Invitation was sent Successfully' do
        let(:user) { create(:user_with_referral) }
        let(:Authorization) { "Basic #{{user: user.id}}" }
        examples 'application/json' => {message: 'Invitations successfully sent'}

        let(:params) {{
          emails: ['johndoe@example.com', 'janedoe@example.com']
        }}

        run_test!
      end
    end
  end
end