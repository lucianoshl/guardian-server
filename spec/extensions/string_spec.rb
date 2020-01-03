# frozen_string_literal: true

describe String do
  it 'string_bug_01' do
    value = 'Set 10, 2019  10:30:32'.to_datetime
    expect(value.class).to eq(Time)
    expect(value.zone).to eq('-03')
    expect(value.strftime('%b %d, %Y %H:%M:%S:%L')).to eq('Sep 10, 2019 10:30:32:000')
  end

  it 'string_bug_02' do
    value = 'set 24, 2019  15:17:28:571'.to_datetime
    expect(value.class).to eq(Time)
    expect(value.zone).to eq('-03')
    expect(value.strftime('%b %d, %Y %H:%M:%S:%L')).to eq('Sep 24, 2019 15:17:28:571')
  end

  it 'string_bug_03' do
    now = Time.now
    Time.stub(:now).and_return(now.change(day: 3, month: 10, year: 2019))
    value = 'hoje às 16:48:17:071'.to_datetime
    expect(value.class).to eq(Time)
    expect(value.zone).to eq('-03')
    expect(value.strftime('%b %d, %Y %H:%M:%S:%L')).to eq('Oct 03, 2019 16:48:17:071')
  end

  it 'string_bug_04' do
    value = 'em 27.09. às 19:58:56:071'.to_datetime
    expect(value.class).to eq(Time)
    expect(value.zone).to eq('-03')
    expect(/Sep 27, \d{4} 19:58:56:071/).to match(value.strftime('%b %d, %Y %H:%M:%S:%L'))
  end

  it 'string_bug_05' do
    value = '22.09. às 13:45:071'.to_datetime
    expect(value.class).to eq(Time)
    expect(value.zone).to eq('-03')
    expect(/Sep 22, \d{4} 13:45:07:000/).to match(value.strftime('%b %d, %Y %H:%M:%S:%L'))
  end

  it 'string_bug_06' do
    value = 'em 29.09. às 17:13'.to_datetime
    expect(value.class).to eq(Time)
    value.zone.eql?('-03')
    expect(/Sep 29, \d{4} 17:13:00:000/).to match(value.strftime('%b %d, %Y %H:%M:%S:%L'))
  end

  it 'string_bug_07' do
    value = 'em 29.11. às 17:13'.to_datetime
    expect(value.class).to eq(Time)
    value.zone.eql?('-03')
    expect(/Nov 29, \d{4} 17:13:00:000/).to match(value.strftime('%b %d, %Y %H:%M:%S:%L'))
  end

  it 'string_bug_08' do
    now = Time.now
    Time.stub(:now).and_return(now.change(day: 1, month: 12, year: 2019))
    value = 'em 01.01. às 03:36'.to_datetime
    expect(value.class).to eq(Time)
    expect(value.zone).to eq('-02')
    expect(value.strftime('%b %d, %Y %H:%M:%S:%L')).to eq('Jan 01, 2019 03:36:00:000')
  end
end
