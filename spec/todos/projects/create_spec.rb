# frozen_string_literal: true

require 'rails_helper'

describe 'POST /projects', type: :request do
  subject { response }

  let(:params) { { name: 'Foo Bar' } }

  context 'without files' do
    let(:project) { Project.find_by(name: 'Foo Bar') }

    before do
      post '/projects', params: params.to_json
    end

    it { is_expected.to have_http_status(:created) }
    it { expect(response.body).to eq_json(project) }
    it { expect(project.files).to eq([]) }
  end

  context 'with files as an array of objects' do
    let(:files) { [{ foo: 'bar' }, { bar: 'foo' }] }
    let(:params) { { name: 'Foo Bar', files: files } }
    let(:project) { Project.find_by(name: 'Foo Bar') }

    before do
      post '/projects', params: params.to_json
    end

    it { is_expected.to have_http_status(:created) }
    it { expect(response.body).to eq_json(project) }
    it { expect(project.files).to eq_json(files) }
  end

  context 'with files as an array of strings' do
    let(:files) { %w[foo bar] }
    let(:params) { { name: 'Foo Bar', files: files } }
    let(:project) { Project.find_by(name: 'Foo Bar') }

    before do
      post '/projects', params: params.to_json
    end

    it { is_expected.to have_http_status(:created) }
    it { expect(response.body).to eq_json(project) }
    it { expect(project.files).to eq_json(files) }
  end

  context 'with files as an array of numbers' do
    let(:files) { [1, 2, 3] }
    let(:params) { { name: 'Foo Bar', files: files } }
    let(:project) { Project.find_by(name: 'Foo Bar') }

    before do
      post '/projects', params: params.to_json
    end

    it { is_expected.to have_http_status(:created) }
    it { expect(response.body).to eq_json(project) }
    it { expect(project.files).to eq_json(files) }
  end

  context 'with invalid param' do
    let(:params) do
      { name: 'Foo Bar', foo: 'bar' }
    end

    let(:error) do
      {
        id: 'bad_request',
        message: "Invalid request.\n\n#: failed schema " \
          '#/definitions/project/links/2/schema: "foo" is not a permitted key.'
      }
    end

    before do
      post '/projects', params: params.to_json
    end

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response.body).to eq_json(error) }
  end

  context 'with id param' do
    let(:params) do
      { name: 'Foo Bar', id: 123 }
    end

    let(:error) do
      {
        id: 'bad_request',
        message: "Invalid request.\n\n#: failed schema " \
          '#/definitions/project/links/2/schema: "id" is not a ' \
          'permitted key.'
      }
    end

    before do
      post '/projects', params: params.to_json
    end

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response.body).to eq_json(error) }
  end

  context 'with created_at param' do
    let(:params) do
      {
        name: 'Foo Bar',
        created_at: '2018-11-13T20:20:39+00:00'
      }
    end

    let(:error) do
      {
        id: 'bad_request',
        message: "Invalid request.\n\n#: failed schema " \
          '#/definitions/project/links/2/schema: "created_at" is not a ' \
          'permitted key.'
      }
    end

    before do
      post '/projects', params: params.to_json
    end

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response.body).to eq_json(error) }
  end

  context 'with updated_at param' do
    let(:params) do
      {
        name: 'Foo Bar',
        updated_at: '2018-11-13T20:20:39+00:00'
      }
    end

    let(:error) do
      {
        id: 'bad_request',
        message: "Invalid request.\n\n#: failed schema " \
          '#/definitions/project/links/2/schema: "updated_at" is not a ' \
          'permitted key.'
      }
    end

    before do
      post '/projects', params: params.to_json
    end

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response.body).to eq_json(error) }
  end

  context 'without all required params' do
    let(:params) { {} }

    let(:error) do
      {
        id: 'bad_request',
        message: "Invalid request.\n\n#: failed schema " \
          '#/definitions/project/links/2/schema: "name" wasn\'t supplied.'
      }
    end

    before do
      post '/projects', params: params.to_json
    end

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response.body).to eq_json(error) }
  end

  context 'without current user' do
    let(:headers) { { 'access-token' => nil } }

    before do
      post '/projects', params: params.to_json, headers: headers
    end

    it { is_expected.to have_http_status(:unauthorized) }
  end

  context 'when current user is not admin but is a supervisor' do
    before do
      current_user.update! admin: false, supervisor: true
      post '/projects', params: params.to_json
    end

    it { is_expected.to have_http_status(:created) }
  end

  context 'when current user is not admin or supervisor' do
    before do
      current_user.update! admin: false, supervisor: false
      post '/projects', params: params.to_json
    end

    it { is_expected.to have_http_status(:created) }
  end
end
