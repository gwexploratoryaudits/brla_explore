from scipy.stats import hypergeom
from typing import List


num_sims = 100000


def get_risk_level(votes_for_winner: int, audit_size: int) -> float:
    bpd = hypergeom.pmf(votes_for_winner, num_sims, range(num_sims + 1), audit_size)
    bpd /= sum(bpd)

    risk_level = sum(bpd[range(num_sims // 2 + 1)])

    return risk_level


def get_stopping_size(audit_size: int, risk_limit: float) -> int:
    lo, hi = 0, audit_size
    while lo < hi:
        md = (lo + hi) // 2
        risk_level = get_risk_level(md, audit_size)

        if risk_level == risk_limit:
            return md

        if risk_level < risk_limit:
            prev_risk_level = get_risk_level(md - 1, audit_size)
            if prev_risk_level == risk_limit:
                return md - 1
            if prev_risk_level > risk_limit:
                return md
            hi = md - 1

        else:
            lo = md + 1

    return lo


