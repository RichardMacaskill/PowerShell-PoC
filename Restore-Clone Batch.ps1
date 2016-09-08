$result = Show-InstantCloneClones | Measure-Object -Line | select Lines
for ($i=0;$i -lt $result.Lines;$i++)
{
    Restore-InstantClone -Verbose
};

Show-InstantCloneClones -Verbose | select CloneDatabase, CloneStatus