# # frozen_string_literal: true

# describe Session do
#   it 'convert to desktop cookies' do
#     mobile_client = Client::Mobile.new
#     mobile_client.login 

#     desktop_client = Client::Desktop.new
#     desktop_client.login

#     mobile = mobile_client.cookies
#     desktop = desktop_client.cookies

#     expect(mobile.size).not_to eq(0)
#     expect(desktop.size).not_to eq(0)

#     fake_session = Session.new
#     fake_session.cookies = mobile.map { |raw| Cookie.new(JSON.parse(raw.to_json)) }

#     desktop = (JSON.parse desktop.to_json).sort_by {|a| a['name']}
#     mobile = (JSON.parse mobile.to_json).sort_by {|a| a['name']}
#     converted = JSON.parse(fake_session.desktop_session.cookies.map(&:to_raw).to_json).sort_by {|a| a['name']}

#     converted.each_with_index do |cookie1, index|
#       cookie2 = desktop[index]
#       diff = HashDiff.diff(cookie1, cookie2)
#       diff = diff.reject { |_type, field, _diffs| %w[accessed_at created_at].include?(field) }
#       binding.pry if diff.size > 0
#       expect(diff.size).to eq(0)
#     end
#   end
# end
