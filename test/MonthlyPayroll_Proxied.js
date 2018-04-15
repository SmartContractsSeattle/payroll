const MonthlyPayroll = artifacts.require('MonthlyPayroll');
const MonthlyPayroll_V2 = artifacts.require('MonthlyPayroll_V2');
const UpgradeableContractProxy = artifacts.require('UpgradeableContractProxy');

contract('MonthlyPayroll', ([_, proxyOwner, employee]) => {
    let monthlyPayroll = null;
    let proxy = null;
    beforeEach(async () => {
        const monthlyPayrollWithoutProxy = await MonthlyPayroll.new({ from: proxyOwner });
        proxy = await UpgradeableContractProxy.new({ from: proxyOwner });
        await proxy.updateImplementation(monthlyPayrollWithoutProxy.address, { from: proxyOwner });

        monthlyPayroll = await MonthlyPayroll.at(proxy.address);
        console.log("###### Contracts");
        console.log("###### Proxy: "+proxy.address);
        console.log("###### MonthlyPayroll: "+monthlyPayrollWithoutProxy.address);
    });

    it('should update employee pay', async () => {
        console.log('###### -> Upserting employee monthly pay: '+monthlyPayroll.address);
        await monthlyPayroll.upsertEmployeeMonthlyPay([employee], [1], { from: proxyOwner });

        const pay = await monthlyPayroll.getEmployeePay(employee);

        console.log('###### -> Monthly pay for employee is '+pay);
        assert(pay > 0, "Pay should be greater than zero");
    });

    it('updates employee pay, upgrades contract and then removes employee', async () => {
        console.log('###### -> Upserting employee monthly pay: '+monthlyPayroll.address);
        await monthlyPayroll.upsertEmployeeMonthlyPay([employee], [1], { from: proxyOwner });

        const pay = await monthlyPayroll.getEmployeePay(employee);

        console.log('###### -> Monthly pay for employee is '+pay);
        assert(pay > 0, "Pay should be greater than zero");

        const monthlyPayroll_V2_withoutProxy = await MonthlyPayroll_V2.new({ from: proxyOwner });

        console.log('###### -> Upgrade implementation to MonthlyPayroll_V2 at '+monthlyPayroll_V2_withoutProxy.address);
        await proxy.updateImplementation(monthlyPayroll_V2_withoutProxy.address, { from: proxyOwner });

        const currImplementation = await proxy.implementation({ from: proxyOwner });
        assert.equal(currImplementation, monthlyPayroll_V2_withoutProxy.address);

        const monthlyPayroll_V2 = await MonthlyPayroll_V2.at(proxy.address);

        console.log('###### -> Removing employee: '+monthlyPayroll_V2.address);
        await monthlyPayroll_V2.removeEmployee(employee, { from: proxyOwner });

        const newPay = await monthlyPayroll.getEmployeePay(employee);
        console.log('###### -> Monthly pay for employee is '+newPay);
        assert(newPay == 0, "Pay should be zero");
    });
})