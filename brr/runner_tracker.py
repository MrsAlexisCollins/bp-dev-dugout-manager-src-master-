from nested_dict import nested_dict

class RunnerTracker:
    def __init__(self):
        self.runners = nested_dict(5, int)

    def increment_runs(self, season, level_id, outs, base):
        self.runners[season][level_id][outs][base]['runs'] += 1

    def increment_total(self, season, level_id, outs, base):
        self.runners[season][level_id][outs][base]['total'] += 1

    def results(self):
        return self.runners

    def add(self, counts): # takes another RunnerTracker)
        r = counts.results()
        for season in r:
            for level_id in r[season]:
                for outs in r[season][level_id]:
                    for base in r[season][level_id][outs]:
                        for key in r[season][level_id][outs][base]:
                            self.runners[season][level_id][outs][base][key] += \
                                r[season][level_id][outs][base][key]

