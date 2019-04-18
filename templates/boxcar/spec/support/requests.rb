shared_examples_for "a successful request" do
  it "responds with 200" do
    # SmashingDocs.information(:endpoint_title, doc_message)
    subject
    expect(response).to be_successful
    # SmashingDocs.run!(request, response)
  end
end

shared_examples_for "an invalid request" do |objs|
  it "responds with a 422, including the correct error" do
    subject
    expect(response).to have_http_status(422)
    expect(json_response["errors"]).to include(objs)
  end
end

shared_examples_for "an unauthorized request" do
  it "responds with a 401" do
    subject
    expect(response).to have_http_status(401)
  end
end
