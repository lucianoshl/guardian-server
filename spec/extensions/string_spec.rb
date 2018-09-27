# frozen_string_literal: true

describe String do
  it 'string_bug_01' do
    value = 'Set 10, 2018  10:30:32'.to_datetime
    expect(value.class).to eq(Time)
    value.zone.eql?('-03')
  end

  it 'string_bug_02' do
    value = 'set 24, 2018  15:17:28:571'.to_datetime
    expect(value.class).to eq(Time)
    value.zone.eql?('-03')
  end

  it 'string_bug_03' do
    value = 'hoje às 16:48:17:071'.to_datetime
    expect(value.class).to eq(Time)
    value.zone.eql?('-03')
  end

  it 'string_bug_04' do
    value = 'em 27.09. às 19:58:56:071'.to_datetime
    expect(value.class).to eq(Time)
    value.zone.eql?('-03')
  end

  it 'string_bug_05' do
    value = '22.09. às 13:45:071'.to_datetime
    expect(value.class).to eq(Time)
    value.zone.eql?('-03')
  end

  it 'string_bug_06' do
    value = 'em 29.09. às 17:13'.to_datetime
    expect(value.class).to eq(Time)
    value.zone.eql?('-03')
  end

  

  
end
