Code.require_file "test_helper.exs", __DIR__

defmodule FakeCalendar do
  def to_string(_), do: "boom"
end

defmodule DateTest do
  use ExUnit.Case, async: true
  doctest Date

  test "to_string/1" do
    assert to_string(~D[2000-01-01]) == "2000-01-01"

    date = Map.put(~D[2000-01-01], :calendar, FakeCalendar)
    assert to_string(date) == "boom"
  end

  test "inspect/1" do
    assert inspect(~D[2000-01-01]) == "~D[2000-01-01]"

    date = Map.put(~D[2000-01-01], :calendar, FakeCalendar)
    assert inspect(date) == "%Date{calendar: FakeCalendar, day: 1, month: 1, year: 2000}"
  end
end

defmodule TimeTest do
  use ExUnit.Case, async: true
  doctest Time

  test "to_string/1" do
    assert to_string(~T[23:00:07.005]) == "23:00:07.005"
  end

  test "inspect/1" do
    assert inspect(~T[23:00:07.005]) == "~T[23:00:07.005]"
  end
end

defmodule NaiveDateTimeTest do
  use ExUnit.Case, async: true
  doctest NaiveDateTime

  test "to_string/1" do
    assert to_string(~N[2000-01-01 23:00:07.005]) == "2000-01-01 23:00:07.005"

    date = Map.put(~N[2000-01-01 23:00:07.005], :calendar, FakeCalendar)
    assert to_string(date) == "boom"
  end

  test "inspect/1" do
    assert inspect(~N[2000-01-01 23:00:07.005]) == "~N[2000-01-01 23:00:07.005]"

    date = Map.put(~N[2000-01-01 23:00:07.005], :calendar, FakeCalendar)
    assert inspect(date) == "%NaiveDateTime{calendar: FakeCalendar, day: 1, hour: 23, " <>
                            "microsecond: {5000, 3}, minute: 0, month: 1, second: 7, year: 2000}"
  end
end

defmodule DateTimeTest do
  use ExUnit.Case, async: true
  doctest DateTime

  test "to_string/1" do
    datetime = %DateTime{
      year: 2000, month: 2, day: 29, zone_abbr: "BRM",
      hour: 23, minute: 0, second: 7, microsecond: {0, 0},
      utc_offset: -12600, std_offset: 3600, time_zone: "Brazil/Manaus"
    }
    assert to_string(datetime) == "2000-02-29 23:00:07-02:30 BRM Brazil/Manaus"
  end

  test "from_unix/2" do
    # with Unix times back to 0 Gregorian Seconds
    datetime = %DateTime{
      calendar: Calendar.ISO, day: 1, hour: 0, microsecond: {0, 0},
      minute: 0, month: 1, second: 0, std_offset: 0, time_zone: "Etc/UTC",
      utc_offset: 0, year: 0, zone_abbr: "UTC"
    }
    assert DateTime.from_unix(-62167219200) == {:ok, datetime}

    assert DateTime.from_unix(-62167219201) == :error
  end

  test "from_unix!/2" do
    # with Unix times back to 0 Gregorian Seconds
    datetime = %DateTime{
      calendar: Calendar.ISO, day: 1, hour: 0, microsecond: {0, 0},
      minute: 0, month: 1, second: 0, std_offset: 0, time_zone: "Etc/UTC",
      utc_offset: 0, year: 0, zone_abbr: "UTC"
    }
    assert DateTime.from_unix!(-62167219200) == datetime

    assert_raise ArgumentError, "invalid Unix time -62167219201", fn ->
      DateTime.from_unix!(-62167219201)
    end
  end

  test "to_unix/2 works with Unix times back to 0 Gregorian Seconds" do
    # with Unix times back to 0 Gregorian Seconds
    gregorian_0 = %DateTime{calendar: Calendar.ISO, day: 1, hour: 0, microsecond: {0, 0},
                            minute: 0, month: 1, second: 0, std_offset: 0, time_zone: "Etc/UTC",
                            utc_offset: 0, year: 0, zone_abbr: "UTC"}
    assert DateTime.to_unix(gregorian_0) == -62167219200

    before_gregorian_0 = %DateTime{gregorian_0 | year: -1}
    assert_raise FunctionClauseError, fn ->
      DateTime.to_unix(before_gregorian_0)
    end
  end
end
