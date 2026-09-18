from app.models import severity_for


def test_low_risk():
    assert severity_for(1) == "Low"
    assert severity_for(5) == "Low"


def test_medium_risk():
    assert severity_for(6) == "Medium"
    assert severity_for(11) == "Medium"


def test_high_risk():
    assert severity_for(12) == "High"
    assert severity_for(19) == "High"


def test_critical_risk():
    assert severity_for(20) == "Critical"
    assert severity_for(25) == "Critical"
