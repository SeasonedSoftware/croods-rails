# frozen_string_literal: true

require 'rails_helper'

describe 'DELETE /users/:id', type: :request do
  subject { response }

  let(:user) do
    current_organization.users
      .create! email: 'foo@bar.com', name: 'Foo Bar', password: 'foobar'
  end

  let(:one_organization) { Organization.create!(name: 'Foo', slug: 'foo') }
  let(:another_organization) { Organization.create!(name: 'Bar', slug: 'bar') }

  let(:one_user) do
    one_organization.users
      .create! email: 'one@another.com', name: 'Foo Bar', password: 'foobar'
  end

  let(:another_user) do
    another_organization.users
      .create! email: 'another@another.com', name: 'Bar Foo', password: 'barfoo'
  end

  before do
    one_user
    another_user
  end

  context 'with valid request' do
    before do
      delete "/users/#{user.id}"
    end

    it { is_expected.to have_http_status(:ok) }
    it { expect(response.body).to eq_json(user) }
    it { expect(User.find_by(email: 'foo@bar.com')).to be_nil }
  end

  context 'with invalid request' do
    let(:error) do
      {
        id: 'bad_request',
        message: "Invalid request.\n\n#: failed schema " \
          '#/definitions/user/links/3/schema: "foo" is not a ' \
          'permitted key.'
      }
    end

    before do
      delete "/users/#{user.id}", params: { foo: 'bar' }.to_json
    end

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response.body).to eq_json(error) }
    it { expect(User.find_by(email: 'foo@bar.com')).to eq(user) }
  end

  context 'with record not found' do
    let(:id) { user.id + 1 }

    let(:error) do
      {
        id: 'not_found',
        message: "Couldn't find User with 'id'=#{id} " \
           '[WHERE "users"."organization_id" = $1]'
      }
    end

    before do
      delete "/users/#{id}"
    end

    it { is_expected.to have_http_status(:not_found) }
    it { expect(response.body).to eq_json(error) }
  end

  context 'without current user' do
    let(:headers) { { 'access-token' => nil } }

    before do
      delete "/users/#{user.id}", headers: headers
    end

    it { is_expected.to have_http_status(:unauthorized) }
  end

  context 'when current user is not admin but is a supervisor' do
    before do
      current_user.update! admin: false, supervisor: true
      delete "/users/#{user.id}"
    end

    it { is_expected.to have_http_status(:forbidden) }
  end

  context 'when current user is not admin or supervisor' do
    let(:error) do
      {
        id: 'forbidden',
        message: 'not allowed to destroy? this User'
      }
    end

    before do
      current_user.update! admin: false, supervisor: false
      delete "/users/#{user.id}"
    end

    it { is_expected.to have_http_status(:forbidden) }
    it { expect(response.body).to eq_json(error) }
  end

  context 'when user is from another organization' do
    let(:id) { another_user.id }

    let(:error) do
      {
        id: 'not_found',
        message: "Couldn't find User with 'id'=#{id} " \
           '[WHERE "users"."organization_id" = $1]'
      }
    end

    before do
      delete "/users/#{id}"
    end

    it { is_expected.to have_http_status(:not_found) }
    it { expect(response.body).to eq_json(error) }
  end
end
