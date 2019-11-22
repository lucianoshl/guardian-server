# frozen_string_literal: true

describe Service::Report do
  it 'just sync' do
    mock_request_from_id('report_list')
    Service::Report.sync
  end

  it 'report_with_old_player' do
    mock_request_from_id('report_with_old_player')
    report = Screen::ReportView.new(view: 15_326_288).report

    expect(report.erase_uri.empty?).to be_falsey
    expect(report.moral).to eq(100)
    expect(report.dot).to eq('red')
    expect(report.ocurrence.to_i).to eq(Time.zone.strptime('2019-08-12T23:17:58', '%FT%T').to_i)
    expect(report.luck).to eq(-21)
    expect(report.night_bonus).to eq(false)
    expect(report.read).to eq(false)
    expect(report.full_pillage).to eq(nil)
    expect(report.origin_id).to eq(7002)
    expect(report.target_id).to eq(7863)

    expect(report.resources).to eq(nil)
    expect(report.pillage).to eq(nil)
    expect(report.buildings).to eq(nil)

    atk_troops = report.atk_troops
    expect(atk_troops.to_h.values.sum).to eq(1)
    expect(atk_troops.spy).to eq(1)
    atk_losses = report.atk_losses
    expect(atk_losses.to_h.values.sum).to eq(1)
    expect(atk_losses.spy).to eq(1)
    expect(report.atk_bonus).to eq([])

    expect(report.def_troops).to eq(nil)
    expect(report.def_losses).to eq(nil)
    expect(report.def_bonus).to eq([])
    expect(report.def_away).to eq(nil)

    expect(report.catapult_damage).to eq(nil)
    expect(report.ram_damage).to eq(nil)
    expect(report.extra_info).to eq([])
  end

  it 'report with conquer' do
    mock_request_from_id('report_with_conquer')
    report = Screen::ReportView.new(view: 24_273_855).report

    expect(report.erase_uri.empty?).to be_falsey
    expect(report.moral).to eq(100)
    expect(report.dot).to eq('green')
    expect(report.ocurrence.to_i).to eq(Time.zone.strptime('2019-08-22T13:05:37', '%FT%T').to_i)
    expect(report.luck).to eq(-24.7)
    expect(report.night_bonus).to eq(false)
    expect(report.read).to eq(false)
    expect(report.full_pillage).to eq(false)
    expect(report.origin_id).to eq(7002)
    expect(report.target_id).to eq(7832)

    expect(report.resources).to eq(nil)
    expect(report.pillage.sum).to eq(0)
    expect(report.buildings).to eq(nil)

    atk_troops = report.atk_troops
    expect(atk_troops.to_h.values.sum).to eq(101)
    expect(atk_troops.snob).to eq(1)
    expect(atk_troops.axe).to eq(100)
    atk_losses = report.atk_losses
    expect(atk_losses.to_h.values.sum).to eq(0)

    expect(report.def_troops.sum).to eq(0)
    expect(report.def_losses.sum).to eq(0)
    expect(report.def_bonus).to eq([])
    expect(report.def_away).to eq(nil)

    expect(report.catapult_damage).to eq(nil)
    expect(report.ram_damage).to eq(nil)
    expect(report.extra_info).to eq([])
  end
end
