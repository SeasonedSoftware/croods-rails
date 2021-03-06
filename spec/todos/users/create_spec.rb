# frozen_string_literal: true

require 'rails_helper'

describe 'POST /users', type: :request do
  subject { response }

  let(:params) { { email: 'foo@bar.com', name: 'Foo Bar', password: 'foobar' } }

  context 'with valid params' do
    let(:user) { User.find_by(email: 'foo@bar.com') }

    before do
      post '/users', params: params.to_json
    end

    it { is_expected.to have_http_status(:created) }
    it { expect(response.body).to eq_json(user) }
  end

  context 'with invalid param' do
    let(:params) do
      { email: 'foo@bar.com', name: 'Foo Bar', password: 'foobar', foo: 'bar' }
    end

    let(:error) do
      {
        id: 'bad_request',
        message: "Invalid request.\n\n#: failed schema " \
          '#/definitions/user/links/1/schema: "foo" is not a permitted key.'
      }
    end

    before do
      post '/users', params: params.to_json
    end

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response.body).to eq_json(error) }
  end

  context 'with admin param' do
    let(:params) do
      { email: 'foo@bar.com', name: 'Foo Bar', password: 'foobar', admin: true }
    end

    let(:error) do
      {
        id: 'bad_request',
        message: "Invalid request.\n\n#: failed schema " \
          '#/definitions/user/links/1/schema: "admin" is not a permitted key.'
      }
    end

    before do
      post '/users', params: params.to_json
    end

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response.body).to eq_json(error) }
  end

  context 'with id param' do
    let(:params) do
      { email: 'foo@bar.com', name: 'Foo Bar', password: 'foobar', id: 123 }
    end

    let(:error) do
      {
        id: 'bad_request',
        message: "Invalid request.\n\n#: failed schema " \
          '#/definitions/user/links/1/schema: "id" is not a ' \
          'permitted key.'
      }
    end

    before do
      post '/users', params: params.to_json
    end

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response.body).to eq_json(error) }
  end

  context 'with created_at param' do
    let(:params) do
      {
        email: 'foo@bar.com',
        name: 'Foo Bar',
        password: 'foobar',
        created_at: '2018-11-13T20:20:39+00:00'
      }
    end

    let(:error) do
      {
        id: 'bad_request',
        message: "Invalid request.\n\n#: failed schema " \
          '#/definitions/user/links/1/schema: "created_at" is not a ' \
          'permitted key.'
      }
    end

    before do
      post '/users', params: params.to_json
    end

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response.body).to eq_json(error) }
  end

  context 'with updated_at param' do
    let(:params) do
      {
        email: 'foo@bar.com',
        name: 'Foo Bar',
        password: 'foobar',
        updated_at: '2018-11-13T20:20:39+00:00'
      }
    end

    let(:error) do
      {
        id: 'bad_request',
        message: "Invalid request.\n\n#: failed schema " \
          '#/definitions/user/links/1/schema: "updated_at" is not a ' \
          'permitted key.'
      }
    end

    before do
      post '/users', params: params.to_json
    end

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response.body).to eq_json(error) }
  end

  context 'without all required params' do
    let(:params) { { email: 'foo@bar.com', password: 'foobar' } }

    let(:error) do
      {
        id: 'bad_request',
        message: "Invalid request.\n\n#: failed schema " \
          '#/definitions/user/links/1/schema: "name" wasn\'t supplied.'
      }
    end

    before do
      post '/users', params: params.to_json
    end

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response.body).to eq_json(error) }
  end

  context 'with email already taken' do
    let(:error) do
      {
        id: 'record_invalid',
        message: 'Validation failed: E-mail has already been taken'
      }
    end

    before do
      current_organization.users
        .create! email: 'foo@bar.com', name: 'Foo Bar', password: 'foobar'
      post '/users', params: params.to_json
    end

    it { is_expected.to have_http_status(:unprocessable_entity) }
    it { expect(response.body).to eq_json(error) }
  end

  context 'without current user' do
    let(:headers) { { 'access-token' => nil } }

    before do
      post '/users', params: params.to_json, headers: headers
    end

    it { is_expected.to have_http_status(:unauthorized) }
  end

  context 'when current user is not admin but is a supervisor' do
    before do
      current_user.update! admin: false, supervisor: true
      post '/users', params: params.to_json
    end

    it { is_expected.to have_http_status(:created) }
  end

  context 'when current user is not admin or supervisor' do
    let(:error) do
      {
        id: 'forbidden',
        message: 'not allowed to create? this User'
      }
    end

    before do
      current_user.update! admin: false, supervisor: false
      post '/users', params: params.to_json
    end

    it { is_expected.to have_http_status(:forbidden) }
    it { expect(response.body).to eq_json(error) }
  end
end
